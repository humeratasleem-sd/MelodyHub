const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const multer = require("multer");
const fs = require("fs");
const path = require("path");
const mongoose = require("mongoose");

const app = express();
const PORT = 5000;

//  MongoDB connection
mongoose.connect("mongodb://127.0.0.1:27017/melodyhub")
  .then(() => console.log(" MongoDB Connected"))
  .catch(err => console.error(" MongoDB Error:", err));

//  Define User Schema and Model
const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
});

const User = mongoose.model("User", userSchema);

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

//  Register endpoint (Save to MongoDB)
app.post("/api/register", async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Check if username or email already exists
    const existingUser = await User.findOne({ $or: [{ username }, { email }] });
    if (existingUser) {
      return res.status(400).json({ error: "Username or email already exists" });
    }

    // Save new user to MongoDB
    const newUser = new User({ username, email, password });
    await newUser.save();

    res.json({ message: "User registered successfully", user: newUser });
  } catch (err) {
    console.error("Register Error:", err);
    res.status(500).json({ error: "Failed to register user" });
  }
});

//  Login endpoint (Validate from MongoDB)
app.post("/api/login", async (req, res) => {
  try {
    const { username, password } = req.body;

    const user = await User.findOne({ username, password });
    if (!user) return res.status(400).json({ error: "Invalid credentials" });

    res.json({ message: "Login successful", user });
  } catch (err) {
    console.error("Login Error:", err);
    res.status(500).json({ error: "Failed to login" });
  }
});

//  Multer setup for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/"),
  filename: (req, file, cb) => cb(null, Date.now() + "-" + file.originalname),
});
const upload = multer({ storage });

//  Get all songs
app.get("/api/songs", (req, res) => {
  fs.readdir("uploads", (err, files) => {
    if (err) return res.status(500).json({ error: "Failed to load songs" });
    const songs = files.filter((f) => f.endsWith(".mp3"));
    res.json(songs);
  });
});

//  Upload new song
app.post("/api/songs", upload.single("song"), (req, res) => {
  res.json({ message: "Song uploaded successfully", file: req.file.filename });
});

//  Delete song
app.delete("/api/songs/:name", (req, res) => {
  const songName = req.params.name;
  const filePath = path.join(__dirname, "uploads", songName);
  fs.unlink(filePath, (err) => {
    if (err) return res.status(404).json({ error: "File not found" });
    res.json({ message: "Song deleted" });
  });
});

//  Start server
app.listen(PORT, () => console.log(`Server running on http://127.0.0.1:${PORT}`));
