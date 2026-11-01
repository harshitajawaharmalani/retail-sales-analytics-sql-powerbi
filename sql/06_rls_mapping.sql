USE ecommerce_db;
GO

CREATE TABLE user_city_map (
    user_email VARCHAR(255) NOT NULL,
    city       VARCHAR(100) NOT NULL,
    PRIMARY KEY (user_email, city)
);

INSERT INTO user_city_map (user_email, city) VALUES
('dhaka.manager@company.com',      'DHAKA'),
('chittagong.manager@company.com', 'CHITTAGONG'),
('khulna.manager@company.com',     'KHULNA'),
('regional.head@company.com',      'DHAKA'),
('regional.head@company.com',      'KHULNA'),
('harshita33385@gmail.com',         'DHAKA');    
GO

SELECT * FROM user_city_map;