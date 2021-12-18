DROP TABLE ORDERITEMS_DW;
DROP TABLE PAYMENT_DW;
DROP TABLE ORDERS_DW;
DROP TABLE SELLERS_DW;
DROP TABLE CUSTOMERS_DW;
DROP TABLE ENTITY_DW;
DROP TABLE PRODUCTS_DW;

CREATE TABLE PRODUCTS_DW (
  ProductID         VARCHAR(50) NOT NULL   PRIMARY KEY,
  ProductCategory   VARCHAR(50),
  ProductPhotoCount NUMBER(3),
  ProductWeight     NUMBER(9,2),
  ProductHeight     NUMBER(9,2),
  ProductLength     NUMBER(9,2)
);

CREATE TABLE ENTITY_DW (
  ZipCode       NUMBER(5)  NOT NULL   PRIMARY KEY,
  City          VARCHAR(50),
  State         VARCHAR(2)
);

CREATE TABLE CUSTOMERS_DW (
  CustomerID        VARCHAR(50)  NOT NULL   PRIMARY KEY,
  CustomerZipCode   NUMBER(5)    REFERENCES ENTITY_DW (ZipCode)
);

CREATE TABLE SELLERS_DW (
  SellerID          VARCHAR(50)  NOT NULL   PRIMARY KEY,
  SellerZipCode     NUMBER(5)    REFERENCES ENTITY_DW (ZipCode)
);

CREATE TABLE ORDERS_DW (
  OrderID                   VARCHAR(50)  NOT NULL   PRIMARY KEY,
  CustomerID                VARCHAR(50)  REFERENCES CUSTOMERS_DW (CustomerID),
  OrderStatus               VARCHAR(12),
  Price                     NUMBER(9,2),
  PurchaseTimeStamp         DATE,
  OrderApprovalTimeStamp    DATE,
  OrderDeliveryTimeStamp    DATE,
  ShippingLimitDate         DATE,
  FrieghtValue              NUMBER(9,2)
);

CREATE TABLE PAYMENT_DW (
  OrderID                   VARCHAR(50),
  PaymentSequence           NUMBER,
  PaymentType               VARCHAR(12),
  PaymentInstallment        NUMBER,
  PaymentValue              NUMBER(9,2),
   CONSTRAINT PAYMENT_DW_pk
    PRIMARY KEY (OrderID, PaymentSequence)
);

CREATE TABLE ORDERITEMS_DW (
  OrderID                   VARCHAR(50),
  OrderItemID               NUMBER,
  SellerID                  VARCHAR(50)     REFERENCES SELLERS_DW (SellerID),
  ProductID                 VARCHAR(50)     REFERENCES PRODUCTS_DW (ProductID),
  Price                     NUMBER(9,2),
  FrieghtValue              NUMBER(9,2),
  ShippingLimitDate         DATE,
  CONSTRAINT ORDERITEMS_DW_pk
    PRIMARY KEY (OrderID, OrderItemID),
  CONSTRAINT ORDERITEMS_DW_fk1
    FOREIGN KEY (OrderID)
    REFERENCES ORDERS_DW (OrderID)
);


-----------------------------------------------------ETL SCRIPT FOR DATA WAREHOUSE---------------------------------------------------

INSERT INTO PRODUCTS_DW (ProductID, ProductCategory, ProductPhotoCount, ProductWeight, ProductHeight, ProductLength)
SELECT ProductID, ProductCategory, ProductPhotoCount, ProductWeight, ProductHeight, ProductLength
FROM PRODUCTS;

COMMIT;

INSERT INTO ENTITY_DW (ZipCode, City, State)
SELECT ZipCode, MIN(City) AS CITY, MIN(STATE) AS STATE
FROM
(SELECT CustomerZipCode as ZipCode, min(CustomerCity) as City, min(CustomerState) as State
FROM CUSTOMERS
GROUP BY CustomerZipCode
UNION 
SELECT SellerZipCode as ZipCode, min(SellerCity) as City, min(SellerState) as State
FROM SELLERS
GROUP BY SellerZipCode)
GROUP BY ZipCode;

COMMIT;

INSERT INTO CUSTOMERS_DW (CustomerID, CustomerZipCode)
SELECT CustomerID, CustomerZipCode
FROM CUSTOMERS;

COMMIT;

INSERT INTO SELLERS_DW (SellerID, SellerZipCode)
SELECT SellerID, min(SellerZipCode)
FROM SELLERS
group by SellerID;

COMMIT;

INSERT INTO ORDERS_DW (OrderID, CustomerID, OrderStatus, Price, PurchaseTimeStamp, OrderApprovalTimeStamp, OrderDeliveryTimeStamp, ShippingLimitDate, FrieghtValue)
SELECT  OrderID, MIN(CustomerID), MIN(OrderStatus), MIN(Price), 
MIN(TO_DATE(PurchaseTimeStamp, 'mm/dd/yy hh24:mi')), 
MIN(TO_DATE(OrderApprovalTimeStamp, 'mm/dd/yy hh24:mi')),
MIN(TO_DATE(OrderDeliveryTimeStamp, 'mm/dd/yy hh24:mi')),
MIN(TO_DATE(ShippingLimitDate, 'mm/dd/yy hh24:mi')), 
MIN(FriEghtValue)
FROM ORDERS
WHERE PurchaseTimeStamp IS NOT NULL
AND OrderApprovalTimeStamp IS NOT NULL
AND OrderDeliveryTimeStamp IS NOT NULL
AND ShippingLimitDate IS NOT NULL
GROUP BY ORDERID;

COMMIT;

INSERT INTO PAYMENT_DW (OrderID, PaymentSequence, PaymentType, PaymentInstallment, PaymentValue)
SELECT OrderID, PaymentSequence, MIN(PaymentType), MIN(PaymentInstallment), MIN(PaymentValue)
FROM ORDERS
GROUP BY OrderID, PaymentSequence;

INSERT INTO ORDERITEMS_DW (OrderID, OrderItemID, SellerID, ProductID, Price, FrieghtValue, ShippingLimitDate)
SELECT OrderID, OrderItemID, MIN(SellerID), MIN(ProductID), MIN(Price), MIN(FrieghtValue), 
    MIN(TO_DATE(ShippingLimitDate, 'mm/dd/yy hh24:mi'))
FROM ORDERS
WHERE ORDERID IN (SELECT DISTINCT ORDERID FROM ORDERS_DW)
GROUP BY OrderID, OrderItemID;


COMMIT;