DROP TABLE orders;
DROP TABLE customers;
DROP TABLE sellers;
DROP TABLE products;

CREATE TABLE customers (
  CustomerID VARCHAR(50),
  CustomerZipCode NUMBER(5),
  CustomerCity VARCHAR(50),
  CustomerState VARCHAR(2),
  CONSTRAINT customer_pk PRIMARY KEY(CustomerID)
);

CREATE TABLE sellers (
  SellerID VARCHAR(50),
  SellerZipCode NUMBER(5),
  SellerCity VARCHAR(50),
  SellerState VARCHAR(2),
  CONSTRAINT seller_pk PRIMARY KEY(SellerID)
);

CREATE TABLE products (
  ProductID VARCHAR(50),
  ProductCategory VARCHAR(50),
  ProductPhotoCount NUMBER(3),
  ProductWeight NUMBER(9,2),
  ProductHeight NUMBER(9,2),
  ProductLength NUMBER(9,2),
  ProductWidth NUMBER(9,2),
 CONSTRAINT product_pk  PRIMARY KEY(ProductID)
);

CREATE TABLE orders (
  OrderID VARCHAR(50),
  CustomerID VARCHAR(50) REFERENCES customers(CustomerID),
  SellerID VARCHAR(50)  REFERENCES sellers(SellerID),
  ProductID VARCHAR(50) REFERENCES products(ProductID),
  Price NUMBER(9,2),
  FrieghtValue NUMBER(9,2),
  OrderItemID NUMBER,
  ShippingLimitDate VARCHAR(50),
  OrderStatus VARCHAR(12),
  PurchaseTimeStamp VARCHAR(50),
  OrderApprovalTimeStamp VARCHAR(50),
  OrderDeliveryTimeStamp VARCHAR(50),
  PaymentSequence NUMBER,
  PaymentType VARCHAR(12),
  PaymentInstallment NUMBER,
  PaymentValue NUMBER(9,2),
  CONSTRAINT order_pk PRIMARY KEY (OrderID, OrderItemID, PaymentSequence)
);

