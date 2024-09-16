create table accounts (
    id int serial primary key,
    account varchar not null unique,
    secret varchar not null unique
);
