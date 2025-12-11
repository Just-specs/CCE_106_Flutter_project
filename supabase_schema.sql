-- =====================================================
-- Fresh Petals - Supabase Database Schema
-- =====================================================

-- 1. Create Users Table (extends Supabase auth.users)
CREATE TABLE public.users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user')),
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Users can read their own data
CREATE POLICY "Users can view own profile"
  ON public.users
  FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own data
CREATE POLICY "Users can update own profile"
  ON public.users
  FOR UPDATE
  USING (auth.uid() = id);

-- Allow inserts during signup
CREATE POLICY "Enable insert for authenticated users during signup"
  ON public.users
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- =====================================================

-- 2. Create Products Table
CREATE TABLE public.products (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('Birthday', 'Anniversary', 'Debut', 'Gift', 'Mothersday')),
  image TEXT NOT NULL,
  description TEXT NOT NULL,
  price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity >= 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Anyone can view products
CREATE POLICY "Anyone can view products"
  ON public.products
  FOR SELECT
  USING (true);

-- Only admins can insert products
CREATE POLICY "Admins can insert products"
  ON public.products
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE users.id = auth.uid()
      AND users.role = 'admin'
    )
  );

-- Only admins can update products
CREATE POLICY "Admins can update products"
  ON public.products
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE users.id = auth.uid()
      AND users.role = 'admin'
    )
  );

-- Only admins can delete products
CREATE POLICY "Admins can delete products"
  ON public.products
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE users.id = auth.uid()
      AND users.role = 'admin'
    )
  );

-- =====================================================

-- 3. Create Favorites Table
CREATE TABLE public.favorites (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  product_id BIGINT REFERENCES public.products(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- Enable Row Level Security
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

-- Users can view their own favorites
CREATE POLICY "Users can view own favorites"
  ON public.favorites
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can add to their favorites
CREATE POLICY "Users can add to favorites"
  ON public.favorites
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can delete from their favorites
CREATE POLICY "Users can delete from favorites"
  ON public.favorites
  FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================

-- 4. Create Orders Table
CREATE TABLE public.orders (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'cancelled')),
  delivery_address TEXT NOT NULL,
  contact_number TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Users can view their own orders
CREATE POLICY "Users can view own orders"
  ON public.orders
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can create orders
CREATE POLICY "Users can create orders"
  ON public.orders
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Admins can view all orders
CREATE POLICY "Admins can view all orders"
  ON public.orders
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE users.id = auth.uid()
      AND users.role = 'admin'
    )
  );

-- Admins can update orders
CREATE POLICY "Admins can update orders"
  ON public.orders
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE users.id = auth.uid()
      AND users.role = 'admin'
    )
  );

-- =====================================================

-- 5. Create Order Items Table
CREATE TABLE public.order_items (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id BIGINT REFERENCES public.products(id),
  product_name TEXT NOT NULL,
  product_price DECIMAL(10, 2) NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  subtotal DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- Users can view their own order items
CREATE POLICY "Users can view own order items"
  ON public.order_items
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_items.order_id
      AND orders.user_id = auth.uid()
    )
  );

-- Users can create order items
CREATE POLICY "Users can create order items"
  ON public.order_items
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_items.order_id
      AND orders.user_id = auth.uid()
    )
  );

-- Admins can view all order items
CREATE POLICY "Admins can view all order items"
  ON public.order_items
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE users.id = auth.uid()
      AND users.role = 'admin'
    )
  );

-- =====================================================

-- 6. Create Functions and Triggers

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS \$\$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

-- Trigger for users table
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for products table
CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON public.products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for orders table
CREATE TRIGGER update_orders_updated_at
  BEFORE UPDATE ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================

-- 7. Insert Sample Data

-- Insert sample products (Birthday category)
INSERT INTO public.products (name, category, image, description, price, quantity) VALUES
('Beautiful Birthday', 'Birthday', 'lib/images/birthday/Beautiful birthday.png', 'A stunning arrangement of fresh flowers perfect for birthday celebrations', 1499.00, 10),
('Bright Wishes', 'Birthday', 'lib/images/birthday/Bright Wishes.png', 'Bright and cheerful flowers to celebrate another year', 1299.00, 15),
('Heather Birthday', 'Birthday', 'lib/images/birthday/Heather Birthday.png', 'Elegant heather arrangement for special birthdays', 1399.00, 12),
('Love Sunset', 'Birthday', 'lib/images/birthday/Love Sunset.png', 'Beautiful sunset-themed birthday bouquet', 1599.00, 8),
('Money Galore', 'Birthday', 'lib/images/birthday/Money Galore.png', 'Luxurious birthday gift arrangement', 1799.00, 5);

-- Insert sample products (Anniversary category)
INSERT INTO public.products (name, category, image, description, price, quantity) VALUES
('Cherry Wine', 'Anniversary', 'lib/images/anniversary/Cherry Wine.png', 'Romantic deep red arrangement for anniversaries', 2499.00, 10),
('Chocolate Love', 'Anniversary', 'lib/images/anniversary/Chocolate Love.png', 'Sweet and romantic anniversary bouquet', 2799.00, 8),
('Grand Gesture', 'Anniversary', 'lib/images/anniversary/Grand Gesture.png', 'Make a grand statement on your anniversary', 3499.00, 6),
('Pink Whisper', 'Anniversary', 'lib/images/anniversary/Pink Whisper.png', 'Soft and romantic pink anniversary flowers', 2699.00, 12),
('Sunburst', 'Anniversary', 'lib/images/anniversary/Sunburst.png', 'Bright and beautiful anniversary arrangement', 2999.00, 10);

-- Insert sample products (Debut category)
INSERT INTO public.products (name, category, image, description, price, quantity) VALUES
('Ecuador Elegance', 'Debut', 'lib/images/debut/Ecuador Elegance.png', 'Elegant roses for debut celebrations', 3999.00, 8),
('Giant Teddy Bear Bundle', 'Debut', 'lib/images/debut/Giant Teddy Bear Bundle.png', 'Complete package with teddy bear for debuts', 4899.00, 5),
('Money Galore', 'Debut', 'lib/images/debut/Money Galore.png', 'Luxurious debut gift arrangement', 3299.00, 10),
('Pearl Petals', 'Debut', 'lib/images/debut/Pearl Petals.png', 'Pearl-themed elegant debut flowers', 3699.00, 7),
('Rosey', 'Debut', 'lib/images/debut/Rosey.png', 'Classic rose arrangement for debuts', 3199.00, 12);

-- Insert sample products (Gift category)
INSERT INTO public.products (name, category, image, description, price, quantity) VALUES
('Botanical Majesty', 'Gift', 'lib/images/gift/Botanical Majesty.png', 'Majestic botanical arrangement perfect for any occasion', 2999.00, 10),
('Golden Romance', 'Gift', 'lib/images/gift/Golden Romance.png', 'Golden-themed romantic gift', 3299.00, 8),
('Periwinkle Petals', 'Gift', 'lib/images/gift/Periwinkle Petals.png', 'Unique periwinkle-colored arrangement', 2199.00, 15),
('Pink Moonstone', 'Gift', 'lib/images/gift/Pink Moonstone.png', 'Elegant pink gift arrangement', 3099.00, 10),
('Rose Empress', 'Gift', 'lib/images/gift/Rose Empress.png', 'Imperial rose arrangement for special gifts', 3599.00, 7);

-- Insert sample products (Mother's Day category)
INSERT INTO public.products (name, category, image, description, price, quantity) VALUES
('Heart Glow', 'Mothersday', 'lib/images/Mothersday/Heart Glow.png', 'Warm and loving arrangement for mom', 1999.00, 12),
('Perfect You', 'Mothersday', 'lib/images/Mothersday/Perfect You.png', 'Perfect flowers for the perfect mom', 2299.00, 10),
('Sweet Summer', 'Mothersday', 'lib/images/Mothersday/Sweet Summer.png', 'Sweet summer blooms for Mother''s Day', 2599.00, 8),
('Tender Hearts', 'Mothersday', 'lib/images/Mothersday/Tender Hearts.png', 'Tender arrangement expressing love for mom', 2899.00, 10),
('Wildest Dreams', 'Mothersday', 'lib/images/Mothersday/Wildest Dreams.png', 'Dream arrangement for Mother''s Day', 3299.00, 6);

-- =====================================================

-- 8. Create Admin User (Run this after your first signup)
-- Replace 'YOUR_USER_UUID' with actual user UUID from auth.users table
-- UPDATE public.users SET role = 'admin' WHERE email = 'your-admin-email@example.com';

-- =====================================================
-- Setup Complete!
-- =====================================================
