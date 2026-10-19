-- Categories can be withdrawn from the catalogue without being deleted: their products are moved first.
ALTER TABLE categories ADD COLUMN active BOOLEAN NOT NULL DEFAULT TRUE;
