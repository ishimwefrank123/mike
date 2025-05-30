const Wallet = require('../models/Wallet');

exports.addMoney = async (req, res) => {
  const { userId, amount } = req.body;
  let wallet = await Wallet.findOne({ userId });

  if (!wallet) {
    wallet = new Wallet({ userId, balance: amount });
  } else {
    wallet.balance += amount;
  }

  await wallet.save();
  res.json(wallet);
};

exports.getWallet = async (req, res) => {
  const wallet = await Wallet.findOne({ userId: req.params.userId });
  res.json(wallet || { userId: req.params.userId, balance: 0 });
};
