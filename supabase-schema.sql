-- ================================================================
-- ELOHIM FAST FOOD - Esquema de Base de Datos (Supabase)
-- ================================================================

-- 1. TABLA DE CATEGORÍAS
CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  icon TEXT NOT NULL DEFAULT 'fa-fire',
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. TABLA DE PRODUCTOS
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  price DECIMAL(10,2) NOT NULL,
  category TEXT NOT NULL REFERENCES categories(slug),
  image_url TEXT NOT NULL DEFAULT '',
  badge TEXT DEFAULT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. FUNCIÓN PARA ACTUALIZAR updated_at AUTOMÁTICAMENTE
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- 4. POLÍTICAS DE SEGURIDAD (Row Level Security)
-- Habilitar RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Política: todos pueden LEER categorías y productos activos
CREATE POLICY "Cualquiera puede leer categorías"
  ON categories FOR SELECT USING (TRUE);

CREATE POLICY "Cualquiera puede leer productos activos"
  ON products FOR SELECT USING (active = TRUE);

-- Política: solo admins autenticados pueden ESCRIBIR
CREATE POLICY "Admins pueden insertar productos"
  ON products FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins pueden actualizar productos"
  ON products FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins pueden eliminar productos"
  ON products FOR DELETE USING (auth.role() = 'authenticated');

CREATE POLICY "Admins pueden insertar categorías"
  ON categories FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins pueden actualizar categorías"
  ON categories FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Admins pueden eliminar categorías"
  ON categories FOR DELETE USING (auth.role() = 'authenticated');

-- 5. DATOS INICIALES - CATEGORÍAS
INSERT INTO categories (name, slug, icon, display_order) VALUES
  ('Philly Cheesesteaks', 'philly', 'fa-drumstick-bite', 1),
  ('Hamburguesas', 'hamburguesas', 'fa-burger', 2),
  ('Combos', 'combos', 'fa-bullseye', 3),
  ('Bebidas', 'bebidas', 'fa-wine-glass', 4);

-- 6. DATOS INICIALES - PRODUCTOS
INSERT INTO products (name, description, price, category, image_url, badge, sort_order) VALUES
  ('Philly Clásico', 'Carne de res, queso provolone, cebolla y pimientos salteados.', 10.00, 'philly', 'products/Philly Clásico.webp', 'Más vendido', 1),
  ('Philly con Champiñones', 'Philly clásico bañado en salsa de champiñones y hongos salteados.', 12.00, 'philly', 'products/Philly con Champiñones.webp', NULL, 2),
  ('Philly BBQ', 'Carne, queso cheddar, cebolla caramelizada y salsa BBQ ahumada.', 11.00, 'philly', 'products/Philly BBQ.webp', 'BBQ', 3),
  ('Philly Supremo', 'Doble carne, doble queso, jalapeños, tocineta y salsa especial.', 14.00, 'philly', 'products/Philly Supremo.webp', 'Supremo', 4),
  ('Hamburguesa Clásica', 'Carne 150g, lechuga, tomate, cebolla y nuestra salsa especial.', 8.00, 'hamburguesas', 'products/Hamburguesa Clásica.webp', NULL, 1),
  ('BBQ Bacon', 'Carne 150g, queso cheddar, tocineta crujiente y salsa BBQ.', 10.00, 'hamburguesas', 'products/BBQ Bacon.webp', NULL, 2),
  ('Doble Carne', 'Dos carnes 150g, doble queso, pepinillos, cebolla y aderezo.', 12.00, 'hamburguesas', 'products/Doble Carne.webp', NULL, 3),
  ('Combo Philly', 'Philly Clásico + Papas fritas + Bebida 16oz.', 15.00, 'combos', 'products/Combo Philly.webp', 'Ahorras $3', 1),
  ('Combo Hamburguesa', 'Hamburguesa Clásica + Papas + Bebida 16oz.', 13.00, 'combos', 'products/Combo Hamburguesa.webp', NULL, 2),
  ('Combo Pareja', '2 Philly Clásicos + 2 Papas grandes + 2 Bebidas 20oz.', 25.00, 'combos', 'products/Combo Pareja.webp', 'Para 2', 3),
  ('Coca-Cola', 'Lata 355ml o botella 500ml.', 2.00, 'bebidas', 'products/Coca-Cola.webp', NULL, 1),
  ('Sprite', 'Lata 355ml o botella 500ml.', 2.00, 'bebidas', 'products/Sprite.webp', NULL, 2),
  ('Jugo Natural', 'Parchita, naranja o limonada. Preparado al momento.', 3.00, 'bebidas', 'products/Jugo Natural.webp', NULL, 3),
  ('Agua', 'Botella de agua mineral 500ml.', 1.50, 'bebidas', 'products/Agua.webp', NULL, 4);

-- 7. STORAGE: Bucket para imágenes de productos
-- Ejecuta esto en el SQL Editor de Supabase:
/*
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('products', 'products', true, 5242880, '{"image/png","image/jpeg","image/webp","image/gif"}');

-- Política: cualquiera puede leer imágenes
CREATE POLICY "Public can read product images"
  ON storage.objects FOR SELECT USING (bucket_id = 'products');

-- Política: admins autenticados pueden subir/eliminar
CREATE POLICY "Admins can upload product images"
  ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'products' AND auth.role() = 'authenticated');

CREATE POLICY "Admins can delete product images"
  ON storage.objects FOR DELETE USING (bucket_id = 'products' AND auth.role() = 'authenticated');
*/
