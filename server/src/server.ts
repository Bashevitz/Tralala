import { Server } from "socket.io";
import http from "http";
import { createClient, RedisClientType } from "redis";

export async function startSocketServer(server: http.Server) {
  const redisClient: RedisClientType = createClient({
    url: process.env.REDIS_URL || "redis://localhost:6379",
  });

  redisClient.on("error", (err: Error) =>
    console.error("Redis Client Error:", err)
  );
  await redisClient.connect();

  const io = new Server(server, {
    cors: {
      origin: "*",
    },
  });

  io.on("connection", (socket) => {
    console.log("A user connected:", socket.id);

    socket.on("user:authenticate", async (data) => {
      try {
        const { userId } = data as { userId: string };
        await redisClient.set(`user:${userId}`, socket.id);
        socket.join(userId);
        console.log("User authenticated:", userId);
      } catch (error) {
        console.error("Authentication error:", error);
        socket.emit("error", { message: "Authentication failed" });
      }
    });

    socket.on("chat:join", (userId, chatId) => {
      socket.join(chatId);
      console.log("User " + userId + " joined chat : " + chatId);
    });

    socket.on("chat:leave", (chatId) => {
      socket.leave(chatId);
      console.log("User left chat : " + chatId);
    });

    socket.on("chat:new", async (chat) => {
      const { id, initiator, contacts } = chat as {
        id: string;
        initiator: string;
        contacts: string[];
      };

      console.log(chat);

      for (const contactId of contacts) {
        if (contactId === initiator) continue;
        const contactSocketId = await redisClient.get(`user:${contactId}`);
        if (contactSocketId) {
          io.to(contactSocketId).emit("chat:new", { id, contacts });
        }
      }

      socket.join(id);
    });

    socket.on("message:send", async (message) => {
      const { recipientId } = message;
      const recipientSocketId = await redisClient.get(`user:${recipientId}`);

      if (recipientSocketId) {
        console.log(message);
        io.to(recipientSocketId).emit("message:new", message);
      }
    });

    socket.on("typing:status", async (data) => {
      const { chatId, userId, recipientId, isTyping } = data as {
        chatId: string;
        userId: string;
        recipientId: string;
        isTyping: boolean;
      };

      io.to(recipientId).emit("typing:status", {
        userId,
        chatId,
        isTyping,
      });
    });

    socket.on("disconnect", async () => {
      try {
        // Find and remove the user mapping
        const keys = await redisClient.keys("user:*");
        for (const key of keys) {
          const socketId = await redisClient.get(key);
          if (socketId === socket.id) {
            await redisClient.del(key);
            break;
          }
        }
        socket.emit("user:offline", socket.id);
        socket.emit("user:not_typing", socket.id);
        console.log("User disconnected:", socket.id);
      } catch (error) {
        console.error("Disconnect error:", error);
      }
    });
  });

  // Cleanup function
  return async () => {
    await redisClient.quit();
  };
}
