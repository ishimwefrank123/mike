const Cart = require('../models/Cart');

exports.addToCart = async (req, res) => {
  const { userId, productId, quantity } = req.body;
  let cart = await Cart.findOne({ userId });

  if (!cart) {
    cart = new Cart({ userId, items: [{ productId, quantity }] });
  } else {
    const index = cart.items.findIndex(item => item.productId.toString() === productId);
    if (index > -1) {
      cart.items[index].quantity += quantity;
    } else {
      cart.items.push({ productId, quantity });
    }
  }

  await cart.save();
  res.json(cart);
};

exports.getCart = async (req, res) => {
  const cart = await Cart.findOne({ userId: req.params.userId }).populate('items.productId');
  res.json(cart);
};

exports.removeCartItem = async (req, res) => {
  const { itemId } = req.params;
  const cart = await Cart.findOneAndUpdate(
    { 'items._id': itemId },
    { $pull: { items: { _id: itemId } } },
    { new: true }
  );
  res.json(cart);
};

exports.clearCart = async (req, res) => {
  await Cart.findOneAndDelete({ userId: req.params.userId });
  res.json({ message: 'Cart cleared' });
};
