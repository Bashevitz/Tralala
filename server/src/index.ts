import "dotenv/config";
import express from "express";
import { json } from "body-parser";
import http from "http";
import authRoutes from "./routes/authRoutes";

import contactsRoutes from "./routes/contactsRoutes";
import "./cron/cronJob";
import { startSocketServer } from "./server";
import keysRoutes from "./routes/keys";
const app = express();
const server = http.createServer(app);
app.use(json());

app.use("/auth", authRoutes);
app.use("/keys", keysRoutes);
app.use("/contacts", contactsRoutes);

startSocketServer(server);

const PORT = process.env.PORT || 6000;
server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
