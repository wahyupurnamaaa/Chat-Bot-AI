import express from 'express';
import dotenv from 'dotenv';
import { GoogleGenerativeAI } from '@google/generative-ai';

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json({ limit: '1mb' }));

const apiKey = process.env.GEMINI_API_KEY;

if (!apiKey) {
  console.error('GEMINI_API_KEY tidak ditemukan. Periksa file .env');
  process.exit(1);
}

const genAI = new GoogleGenerativeAI(apiKey);

app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'Backend Gemini aktif' });
});

app.post('/chat', async (req, res) => {
  try {
    const messages = Array.isArray(req.body?.messages) ? req.body.messages : [];

    if (messages.length === 0) {
      return res.status(400).json({ error: 'messages wajib diisi' });
    }

    const lastUserMessage = [...messages].reverse().find((m) => m.role === 'user');
    const prompt = lastUserMessage?.content || 'Halo';

    const model = genAI.getGenerativeModel({ model: 'gemini-3.6-flash' });
    const result = await model.generateContent(prompt);
    const reply = result.response.text();

    return res.json({ reply });
  } catch (error) {
    console.error('Error saat memanggil Gemini:', error);

    return res.status(500).json({
      error: 'Gagal memanggil Gemini',
      detail: error?.message || 'Unknown error',
    });
  }
});

app.listen(port, () => {
  console.log(`Backend berjalan di http://localhost:${port}`);
});
