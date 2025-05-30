const Order = require('../models/Order');
const Cart = require('../models/Cart');
const Wallet = require('../models/Wallet');

exports.placeOrder = async (req, res) => {
  const { userId } = req.body;

  const cart = await Cart.findOne({ userId });
  if (!cart || cart.items.length === 0) {
    return res.status(400).json({ message: 'Cart is empty' });
  }

  const total = cart.items.reduce((sum, item) => sum + item.quantity * 10, 0); // Replace 10 with actual product price if needed
  const wallet = await Wallet.findOne({ userId });

  if (!wallet || wallet.balance < total) {
    return res.status(400).json({ message: 'Insufficient wallet balance' });
  }

  const order = new Order({ userId, items: cart.items, total });
  await order.save();

  wallet.balance -= total;
  await wallet.save();

  await Cart.findOneAndDelete({ userId });

  res.json({ message: 'Order placed', order });
};

exports.getOrders = async (req, res) => {
  const orders = await Order.find({ userId: req.params.userId });
  res.json(orders);
};
