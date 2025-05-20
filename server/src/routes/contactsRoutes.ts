import { Router } from "express";
import {
  findContactByPhone,
  findContactById,
} from "../controllers/contactsController";

const router = Router();

router.get("/phone/:phone", findContactByPhone);
router.get("/id/:id", findContactById);

export default router;
