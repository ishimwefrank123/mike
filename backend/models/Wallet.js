const mongoose = require('mongoose');

const walletSchema = new mongoose.Schema({
  userId: { type: String, required: true, unique: true },
  balance: { type: Number, default: 0 }
}, { timestamps: true });

module.exports = mongoose.model('Wallet', walletSchema);
