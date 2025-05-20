import { Router } from "express";
import {
  fetchKeyBundle,
  registerIdentity,
  uploadKeys,
} from "../controllers/keys";

const router = Router();

router.post("/identity/register", registerIdentity);
router.post("/upload", uploadKeys);
router.get("/fetch/:userId", fetchKeyBundle);

export default router;
