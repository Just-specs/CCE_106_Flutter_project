-- =====================================================
-- CART SYSTEM - SUPABASE SCHEMA
-- Run this in Supabase SQL Editor
-- =====================================================

-- Step 1: Create cart_items table
CREATE TABLE IF NOT EXISTS public.cart_items (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id) -- Prevent duplicate products in cart
);

-- Step 2: Enable RLS
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;

-- Step 3: RLS Policies

-- Users can view their own cart items
DROP POLICY IF EXISTS "Users can view own cart items" ON public.cart_items;
CREATE POLICY "Users can view own cart items"
  ON public.cart_items
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Users can add items to their own cart
DROP POLICY IF EXISTS "Users can insert own cart items" ON public.cart_items;
CREATE POLICY "Users can insert own cart items"
  ON public.cart_items
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own cart items (quantity)
DROP POLICY IF EXISTS "Users can update own cart items" ON public.cart_items;
CREATE POLICY "Users can update own cart items"
  ON public.cart_items
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

-- Users can delete their own cart items
DROP POLICY IF EXISTS "Users can delete own cart items" ON public.cart_items;
CREATE POLICY "Users can delete own cart items"
  ON public.cart_items
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Step 4: Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS \$\$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

-- Step 5: Create trigger for updated_at
DROP TRIGGER IF EXISTS update_cart_items_updated_at ON public.cart_items;
CREATE TRIGGER update_cart_items_updated_at
  BEFORE UPDATE ON public.cart_items
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Step 6: Create view for cart with product details
CREATE OR REPLACE VIEW public.cart_with_products AS
SELECT 
  ci.id,
  ci.user_id,
  ci.product_id,
  ci.quantity,
  ci.created_at,
  ci.updated_at,
  p.name as product_name,
  p.price as product_price,
  p.image as product_image,
  p.description as product_description,
  p.category as product_category,
  (ci.quantity * p.price) as total_price
FROM public.cart_items ci
JOIN public.products p ON ci.product_id = p.id;

-- Step 7: Grant access to view
GRANT SELECT ON public.cart_with_products TO authenticated;

-- Step 8: Verify setup
SELECT 
  tablename, 
  policyname,
  cmd
FROM pg_policies 
WHERE tablename = 'cart_items';

-- Step 9: Test query (optional)
-- SELECT * FROM public.cart_with_products WHERE user_id = auth.uid();

-- =====================================================
-- SUMMARY
-- =====================================================
-- ✅ cart_items table created
-- ✅ RLS enabled and policies set
-- ✅ Updated_at trigger added
-- ✅ View with product details created
-- ✅ Ready to use!

