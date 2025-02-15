create table emp(
    id int comment '编号',
    workno varchar(10) comment '工号',
    name varchar(10) comment '姓名',
    gender char(1) comment '性别',
    age tinyint unsigned comment '年龄',
    idcard char(18) comment '身份证号',
    entrydate date comment '入职时间'
) comment '员工表';

mysql> show tables;
+-------------------+
| Tables_in_student |
+-------------------+
| emp               |
| student           |
+-------------------+
2 rows in set (0.00 sec)

mysql> ALTER TABLE emp ADD nickname varchar(20) COMMENT '';
Query OK, 0 rows affected (0.06 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc emp;
+-----------+---------------------+------+-----+---------+-------+
| Field     | Type                | Null | Key | Default | Extra |
+-----------+---------------------+------+-----+---------+-------+
| id        | int(11)             | YES  |     | NULL    |       |
| workno    | varchar(10)         | YES  |     | NULL    |       |
| name      | varchar(10)         | YES  |     | NULL    |       |
| gender    | char(1)             | YES  |     | NULL    |       |
| age       | tinyint(3) unsigned | YES  |     | NULL    |       |
| idcard    | char(18)            | YES  |     | NULL    |       |
| entrydate | date                | YES  |     | NULL    |       |
| nickname  | varchar(20)         | YES  |     | NULL    |       |
+-----------+---------------------+------+-----+---------+-------+
8 rows in set (0.01 sec)

mysql> ALTER TABLE emp MODIFY nickname varchar(30);
Query OK, 0 rows affected (0.02 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc emp;
+-----------+---------------------+------+-----+---------+-------+
| Field     | Type                | Null | Key | Default | Extra |
+-----------+---------------------+------+-----+---------+-------+
| id        | int(11)             | YES  |     | NULL    |       |
| workno    | varchar(10)         | YES  |     | NULL    |       |
| name      | varchar(10)         | YES  |     | NULL    |       |
| gender    | char(1)             | YES  |     | NULL    |       |
| age       | tinyint(3) unsigned | YES  |     | NULL    |       |
| idcard    | char(18)            | YES  |     | NULL    |       |
| entrydate | date                | YES  |     | NULL    |       |
| nickname  | varchar(30)         | YES  |     | NULL    |       |
+-----------+---------------------+------+-----+---------+-------+
8 rows in set (0.00 sec)

mysql> ALTER TABLE emp CHANGE nickname username varchar(40) COMMENT '';
Query OK, 0 rows affected (0.01 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc emp;
+-----------+---------------------+------+-----+---------+-------+
| Field     | Type                | Null | Key | Default | Extra |
+-----------+---------------------+------+-----+---------+-------+
| id        | int(11)             | YES  |     | NULL    |       |
| workno    | varchar(10)         | YES  |     | NULL    |       |
| name      | varchar(10)         | YES  |     | NULL    |       |
| gender    | char(1)             | YES  |     | NULL    |       |
| age       | tinyint(3) unsigned | YES  |     | NULL    |       |
| idcard    | char(18)            | YES  |     | NULL    |       |
| entrydate | date                | YES  |     | NULL    |       |
| username  | varchar(40)         | YES  |     | NULL    |       |
+-----------+---------------------+------+-----+---------+-------+
8 rows in set (0.00 sec)

mysql> ALTER TABLE emp DROP username;
Query OK, 0 rows affected (0.06 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc emp;
+-----------+---------------------+------+-----+---------+-------+
| Field     | Type                | Null | Key | Default | Extra |
+-----------+---------------------+------+-----+---------+-------+
| id        | int(11)             | YES  |     | NULL    |       |
| workno    | varchar(10)         | YES  |     | NULL    |       |
| name      | varchar(10)         | YES  |     | NULL    |       |
| gender    | char(1)             | YES  |     | NULL    |       |
| age       | tinyint(3) unsigned | YES  |     | NULL    |       |
| idcard    | char(18)            | YES  |     | NULL    |       |
| entrydate | date                | YES  |     | NULL    |       |
+-----------+---------------------+------+-----+---------+-------+
7 rows in set (0.00 sec)

mysql> ALTER TABLE emp RENAME TO employee;
Query OK, 0 rows affected (0.02 sec)

mysql> desc employee;
+-----------+---------------------+------+-----+---------+-------+
| Field     | Type                | Null | Key | Default | Extra |
+-----------+---------------------+------+-----+---------+-------+
| id        | int(11)             | YES  |     | NULL    |       |
| workno    | varchar(10)         | YES  |     | NULL    |       |
| name      | varchar(10)         | YES  |     | NULL    |       |
| gender    | char(1)             | YES  |     | NULL    |       |
| age       | tinyint(3) unsigned | YES  |     | NULL    |       |
| idcard    | char(18)            | YES  |     | NULL    |       |
| entrydate | date                | YES  |     | NULL    |       |
+-----------+---------------------+------+-----+---------+-------+
7 rows in set (0.00 sec)