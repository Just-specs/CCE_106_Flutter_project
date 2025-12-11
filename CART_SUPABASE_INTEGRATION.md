# CART SYSTEM - SUPABASE INTEGRATION

## What Was Added

Created a complete cart system connected to Supabase:
1. ✅ **Cart database table** with RLS policies
2. ✅ **Cart service methods** in SupabaseService
3. ✅ **Product relationship** (cart items linked to products)
4. ✅ **User isolation** (each user has their own cart)
5. ✅ **Real-time sync** across devices

---

## Step 1: Database Setup

### Run This SQL in Supabase

Go to **Supabase Dashboard** → **SQL Editor** → **New Query**

Then run the SQL from: \CART_SUPABASE_SCHEMA.sql\

This creates:
- ✅ \cart_items\ table
- ✅ RLS policies (security)
- ✅ \cart_with_products\ view (with product details)
- ✅ Triggers for updated_at
- ✅ Foreign key relationships

### Database Schema

**cart_items table:**
\\\sql
- id (BIGSERIAL PRIMARY KEY)
- user_id (UUID, references auth.users)
- product_id (INTEGER, references products)
- quantity (INTEGER, default 1)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
- UNIQUE(user_id, product_id)  -- Prevents duplicates
\\\

**cart_with_products view:**
\\\sql
SELECT 
  cart_items.*,
  products.name as product_name,
  products.price as product_price,
  products.image as product_image,
  (quantity * price) as total_price
FROM cart_items
JOIN products ON cart_items.product_id = products.id
\\\

---

## Step 2: Service Methods Added

Added to \lib/services/supabase_service.dart\:

### 1. addToCart()
\\\dart
await _supabaseService.addToCart(
  productId: 1,
  quantity: 2,
);
\\\
- Adds product to cart
- If already exists, increases quantity
- Prevents duplicates

### 2. getCartItems()
\\\dart
final items = await _supabaseService.getCartItems();
// Returns list with product details
\\\
- Gets all cart items for current user
- Includes product name, price, image
- Calculates total_price per item

### 3. updateCartItemQuantity()
\\\dart
await _supabaseService.updateCartItemQuantity(
  cartItemId: 123,
  quantity: 3,
);
\\\
- Updates quantity of specific cart item
- If quantity = 0, removes item

### 4. removeFromCart()
\\\dart
await _supabaseService.removeFromCart(cartItemId: 123);
\\\
- Removes specific item from cart

### 5. clearCart()
\\\dart
await _supabaseService.clearCart();
\\\
- Removes all items from cart
- Useful after checkout

### 6. getCartCount()
\\\dart
final count = await _supabaseService.getCartCount();
// Returns total number of items (sum of all quantities)
\\\
- Gets total item count
- Used for cart badge

### 7. getCartTotal()
\\\dart
final total = await _supabaseService.getCartTotal();
// Returns total price of all items
\\\
- Calculates total price
- Used in cart screen

---

## Step 3: Update Cart Screen (TODO)

Now you need to update \lib/pages/cart_screen.dart\ to use Supabase:

### Current (Local):
\\\dart
// Uses ProductCard.cartProducts (local memory)
final cartProducts = ProductCard.cartProducts;
\\\

### New (Supabase):
\\\dart
// Uses Supabase
Future<List<Map<String, dynamic>>> _loadCartItems() async {
  return await _supabaseService.getCartItems();
}
\\\

---

## Step 4: Update Product Card (TODO)

Update \lib/widgets/product_card.dart\ to add to Supabase cart:

### Current (Local):
\\\dart
ProductCard.cartProducts.add(product);
\\\

### New (Supabase):
\\\dart
await _supabaseService.addToCart(
  productId: product.id,
  quantity: 1,
);
\\\

---

## Features

### User Isolation
- ✅ Each user has their own cart
- ✅ Cart is tied to user_id
- ✅ RLS ensures users only see their cart

### Duplicate Prevention
- ✅ UNIQUE constraint on (user_id, product_id)
- ✅ If adding same product, quantity increases
- ✅ No duplicate entries

### Real-time Sync
- ✅ Cart saved to cloud
- ✅ Accessible from any device
- ✅ Persists across sessions

### Product Details
- ✅ Cart includes product info (name, price, image)
- ✅ Automatic total calculation
- ✅ Join with products table

---

## Security (RLS Policies)

### SELECT (View Cart)
\\\sql
Users can view own cart items
USING (auth.uid() = user_id)
\\\

### INSERT (Add to Cart)
\\\sql
Users can insert own cart items
WITH CHECK (auth.uid() = user_id)
\\\

### UPDATE (Change Quantity)
\\\sql
Users can update own cart items
USING (auth.uid() = user_id)
\\\

### DELETE (Remove Item)
\\\sql
Users can delete own cart items
USING (auth.uid() = user_id)
\\\

**Result:** Users can ONLY access their own cart! 🔒

---

## Benefits Over Local Cart

| Feature | Local Cart | Supabase Cart |
|---------|-----------|---------------|
| Persistence | ❌ Lost on app close | ✅ Saved in cloud |
| Multi-device | ❌ No sync | ✅ Syncs across devices |
| Security | ❌ Can be modified | ✅ Server-side validation |
| Analytics | ❌ No tracking | ✅ Can track abandoned carts |
| Recovery | ❌ Lost forever | ✅ Can recover cart |

---

## Next Steps

### 1. Run SQL Script
\\\ash
# Open Supabase Dashboard
# Go to SQL Editor
# Copy and run: CART_SUPABASE_SCHEMA.sql
\\\

### 2. Update Cart Screen
Update \lib/pages/cart_screen.dart\ to:
- Load cart items from Supabase
- Use FutureBuilder to display items
- Call updateCartItemQuantity() on quantity change
- Call removeFromCart() on delete
- Call clearCart() on checkout

### 3. Update Product Card
Update \lib/widgets/product_card.dart\ to:
- Call addToCart() instead of local list
- Show loading state
- Handle errors
- Update cart badge

### 4. Update HomePage
Update cart badge to use:
\\\dart
final count = await _supabaseService.getCartCount();
\\\

---

## Testing

### Test Add to Cart:
\\\dart
// In any screen
await _supabaseService.addToCart(productId: 1, quantity: 2);
print('Added to cart!');
\\\

### Test Get Cart:
\\\dart
final items = await _supabaseService.getCartItems();
print('Cart has \ items');
\\\

### Test in Supabase:
\\\sql
-- View all cart items
SELECT * FROM public.cart_with_products;

-- View specific user's cart
SELECT * FROM public.cart_with_products 
WHERE user_id = 'user-uuid-here';
\\\

---

## Console Logs

### Add to Cart:
\\\
DEBUG: Adding product 1 to cart (quantity: 2)
DEBUG: Added new item to cart
\\\

### Update Quantity:
\\\
DEBUG: Adding product 1 to cart (quantity: 1)
DEBUG: Updated cart item quantity to 3
\\\

### Get Cart Items:
\\\
DEBUG: Fetching cart items for user abc-123
DEBUG: Found 3 cart items
\\\

---

## Files Created/Modified

| File | Status | Description |
|------|--------|-------------|
| CART_SUPABASE_SCHEMA.sql | ✅ NEW | Database schema for cart |
| lib/services/supabase_service.dart | ✅ UPDATED | Added 7 cart methods |
| CART_SUPABASE_INTEGRATION.md | ✅ NEW | This documentation |

---

## Summary

✅ **Created cart_items table in Supabase**
✅ **Added RLS policies for security**
✅ **Created cart_with_products view**
✅ **Added 7 cart service methods**
✅ **Supports add, update, delete, clear**
✅ **Multi-device sync**
✅ **User isolation**
✅ **Duplicate prevention**
✅ **Real-time updates**

**Next:** Update UI to use these new Supabase cart methods!

---

## Quick Start

1. **Run SQL:**
   \\\ash
   # Open Supabase Dashboard → SQL Editor
   # Copy contents of CART_SUPABASE_SCHEMA.sql
   # Run it
   \\\

2. **Test Methods:**
   \\\dart
   // Add to cart
   await SupabaseService.instance.addToCart(productId: 1);
   
   // Get cart
   final items = await SupabaseService.instance.getCartItems();
   print('Cart: \');
   \\\

3. **Update UI:**
   - Modify cart_screen.dart to use getCartItems()
   - Modify product_card.dart to use addToCart()
   - Update cart badge to use getCartCount()

**Cart system is now ready for Supabase! 🎉**

