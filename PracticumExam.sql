--Question 1

CREATE TABLE Instructor(
INS_ID CHAR(3) NOT NULL,
INS_FNAME VARCHAR2(20) NOT NULL,
INS_SNAME VARCHAR2(30) NOT NULL,
INS_CONTACT VARCHAR2(10) NOT NULL,
INS_LEVEL NUMBER NOT NULL,
CONSTRAINT PK_Instuctor PRIMARY KEY(INS_ID)
)

Create table Customer
(
  CUST_ID       CHAR(4)  not null,
  CUST_FNAME       varchar2(20)  not null,
 CUST_SNAME       varchar2(30)  not null,
  CUST_ADDRESS         varchar2(200)  not null,
  CUST_CONTACT  VARCHAR2(10) not null,
 CONSTRAINT PK_Customer PRIMARY KEY(CUST_ID)
);

CREATE TABLE Dive(
DIVE_ID NUMBER(3) NOT NULL,
DIVE_NAME VARCHAR2(30) NOT NULL,
DIVE_DURATION VARCHAR2(18) NOT NULL,
DIVE_LOCATION VARCHAR2(40) NOT NULL,
DIVE_EXP_LEVEL NUMBER NOT NULL,
DIVE_COST  NUMBER NOT NULL,
CONSTRAINT PK_Dive PRIMARY KEY(DIVE_ID)
);
INSERT ALL 
 INTO DIVE VALUES(550,'Shark Dive','3 hours', 'Shark Point',8,500)
 INTO DIVE VALUES(551,'Coral Dive','1 hour','Break Point',7,300)
 INTO DIVE VALUES(552,'Wave Crescent ','2 hours','Ship wreck ally',3,800)				
 INTO DIVE VALUES(553,'Underwater Exploration','1 hour','Coral ally',2,250)				
 INTO DIVE VALUES(554,'Underwater Adventure','3 hours','Sandy Beach',3,750) 				
 INTO DIVE VALUES(555,'Deep Blue Ocean','30 minutes','Lazy Waves',2,120)				
 INTO DIVE VALUES(556,'Rough Seas','1 hour','Pipe',9,700)
 INTO DIVE VALUES(557,'White Water','2 hours','Drifts',5,200)
 INTO DIVE VALUES(558,'Current Adventur','2 hours',' Rock Lands',3,150)
SELECT * FROM Dual; 

CREATE TABLE Dive_Event(
DIVE_EVENT_ID CHAR(6) NOT NULL,
DIVE_DATE DATE NOT NULL,
DIVE_PARTICIPANTS NUMBER NOT NULL,
INS_ID CHAR(3) NOT NULL,
CUST_ID CHAR(4) NOT NULL,
DIVE_ID NUMBER(3) NOT NULL,
CONSTRAINT PK_Dive_Event PRIMARY KEY(DIVE_EVENT_ID),
CONSTRAINT FK_DE_INS_ID FOREIGN KEY (INS_ID) REFERENCES Instructor(INS_ID),
CONSTRAINT FK_DE_CUST_ID FOREIGN KEY (CUST_ID) REFERENCES Customer(CUST_ID),
CONSTRAINT FK_DE_DIVE_ID FOREIGN KEY (DIVE_ID) REFERENCES DIVE(DIVE_ID)
);

DROP TABLE  dive_event;
drop table  instuctor;

SELECT * FROM Instructor;
SELECT * FROM Customer;
SELECT * FROM dive;
SELECT * FROM dive_event;
--Question 2

CREATE USER gumani IDENTIFIED BY gumani; 
GRANT SELECT, INSERT,UPDATE , DELETE ON PracticumExam.Customer TO gumani;
COMMIT;
/* we are creating user called jack, only have the permission to view the customer table in the practicum exam system */
CREATE USER jack IDENTIFIED BY jack12; 
GRANT SELECT ON PracticumExam.Customer TO jack; 
COMMIT; 

--Question 3

SELECT i.ins_fname||', '||i.ins_sname as INSTRUCTOR,c.cust_fname||', '||c.cust_sname as CUSTOMER,d.dive_location,de.dive_participants FROM instructor i
INNER JOIN dive_event de on de.ins_id = i.ins_id
INNER JOIN dive d on de.dive_id =d.dive_id
INNER JOIN customer c on de.cust_id = c.cust_id
WHERE de.dive_participants BETWEEN 8 AND 10
FETCH FIRST 1 ROWS ONLY;

--Question 4
SET SERVEROUTPUT ON;
DECLARE
v_name Dive.dive_name%TYPE;
v_date Dive_Event.dive_date%TYPE;
v_participants Dive_Event.dive_participants%TYPE;
CURSOR myInfo
IS
SELECT d.dive_name,de.dive_date,de.dive_participants FROM dive d
INNER JOIN dive_event de on d.dive_id = de.dive_id
WHERE de.dive_participants >= 10;
BEGIN
OPEN myInfo;
LOOP
 FETCH myInfo INTO v_name,v_date,v_participants;
 EXIT WHEN myInfo%NOTFOUND;
 dbms_output.put_line('DIVE NAME: '||v_name);
  dbms_output.put_line('DIVE DATE: '||v_date);
   dbms_output.put_line('PARTCIPANTS: '||v_participants);
    dbms_output.put_line('---------------------------------------');
END LOOP;
CLOSE myInfo;
END;
/

--Question 5

SET SERVEROUTPUT ON;
DECLARE
CURSOR myInfo
IS 
SELECT c.cust_fname,c.cust_sname,d.dive_name,de.dive_participants FROM customer c
INNER JOIN dive_event de on c.cust_id = de.cust_id
INNER JOIN dive d on de.dive_id = d.dive_id
ORDER BY c.cust_fname
FETCH FIRST 1 ROWS ONLY; 
v_rec myInfo%ROWTYPE;
BEGIN
FOR v_rec in myinfo
 LOOP
 EXIT WHEN myInfo%NOTFOUND;
 dbms_output.put_line('CUSTOMER: '||v_rec.cust_fname||', '||v_rec.cust_sname);
  dbms_output.put_line('DIVE NAME: '||v_rec.dive_name);
 dbms_output.put_line('PARTICIPANTS: '||v_rec.dive_participants);
    IF v_rec.dive_participants <= 4 THEN  
     dbms_output.put_line('STATUS:  1 instructors required');
    ELSIF v_rec.dive_participants >= 5 AND v_rec.dive_participants <= 7  THEN  
     dbms_output.put_line('STATUS:  2 instructors required');
    ELSE  dbms_output.put_line('STATUS:  3 instructors required');  
    END IF;
  dbms_output.put_line('--------------------------------------'); 
 END LOOP;
END;
/

--Question 6
CREATE OR REPLACE VIEW Vw_Dive_Event
AS
SELECT de.ins_id,c.cust_id,c.cust_address,d.dive_duration,de.dive_date FROM dive_event de 
INNER JOIN dive d on de.dive_id = d.dive_id
INNER JOIN customer c on c.cust_id = de.cust_id
WHERE de.dive_date < '19-Jul-17'
ORDER BY de.dive_date DESC
FETCH FIRST 1 ROWS ONLY;

SELECT * FROM vw_dive_event;
--Question 7

CREATE OR REPLACE TRIGGER New_Dive_Event
BEFORE INSERT OR UPDATE OF dive_participants ON Dive_event
FOR EACH ROW
BEGIN
IF(:New.dive_participants <= 0 OR :New.dive_participants > 20) THEN
RAISE_APPLICATION_ERROR(-20191,'Cannot insert a negative, zero 
participants or more than 20 participants');
END IF;
END;


INSERT INTO Dive_event VALUES('de_110','17-Aug-24',0,'104','C117',555);
INSERT INTO Dive_event VALUES('de_110','17-Aug-24',21,'104','C117',555);


--Question 8
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE sp_Customer_Details(id_inpt char,date_inpt Date)
AS
v_cname Customer.cust_fname%TYPE;
v_sname Customer.cust_sname%TYPE;
v_dname Dive.dive_name%TYPE;
v_date Dive_event.dive_date%TYPE;
CURSOR myInfo
IS
SELECT c.cust_fname,c.cust_sname,d.dive_name,de.dive_date FROM customer c
INNER JOIN dive_event de on de.cust_id = c.cust_id
INNER JOIN dive d on d.dive_id = de.dive_id
WHERE c.cust_id = id_inpt AND de.dive_date = date_inpt;
BEGIN
OPEN myInfo;
LOOP
 FETCH myInfo INTO v_cname,v_sname,v_dname,v_date;
  EXIT WHEN myInfo%NOTFOUND;
  dbms_output.put_line('CUSTOMER DETAILS: '||v_cname||' '||v_sname||' booked for the '||v_dname||' on the '||v_date); 
 END LOOP;
 CLOSE myInfo;
END;
/

EXEC sp_Customer_Details('C115','15-Jul-17');

--Question 9
 -- this function accept a dive id, calculate the sum amount of all dive events and display the dive name and sum and the cost price 
 
 CREATE OR REPLACE FUNCTION Calc_Sum(dive_id Number)
 RETURN varchar2
 AS
 v_dname Dive.dive_name%TYPE; /* using the type operator to inherit the data_type from the table created to the variable*/
  v_cost Dive.dive_cost%TYPE;
 v_sum Dive.dive_cost%TYPE;
 v_details VARCHAR2(100);
 CURSOR myInfo
 IS 
 SELECT d.dive_name,d.dive_cost,SUM(d.dive_cost) as TOTAL FROM dive_event de
 INNER JOIN dive d on d.dive_id = de.dive_id
 WHERE d.dive_id = dive_id
 GROUP BY d.dive_name,d.dive_cost; 
 BEGIN
 
FOR rec in myInfo
LOOP
v_dname := rec.dive_name;
v_cost := rec.dive_cost;
v_sum := rec.total;
v_details := 'Dive name: '||v_dname||',cost price is : R'||v_cost||' , the total amount sold for this event is R'||v_sum;
RETURN v_details;
END LOOP; 
EXCEPTION WHEN OTHERS THEN
 RAISE_APPLICATION_ERROR(-20191,'An Error was encounterd - '||SQLCODE||'-
ERROR-'||SQLERRM);
END;


SET SERVEROUTPUT ON;
DECLARE result VARCHAR2 (100);
BEGIN
SELECT calc_sum(552)
 INTO result FROM DUAL;
DBMS_OUTPUT.PUT_LINE(result);
END;
/
 
--Question 10


--JAVA CODE
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 */

package com.mycompany.practiculum_gui;

import java.util.Scanner;

/**
 *
 * @author RC_student_2024
 */
public class PRACTICULUM_GUI {

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        System.out.println("--------------------------------");
        System.out.println("WELCOME TO IT GEAR DEALER");
        System.out.println("---------------------------------");
        System.out.println("Select one of the options"+"\n"+"  1: Get Customer Details "+"\n"+"  2: Dive event cost");
        int selectedMenu = scanner.nextInt();
        if(selectedMenu == 1){
            System.out.println("Enter the customer ID : ");
            String custId = scanner.next();
             System.out.println("Enter the dive date : ");     
             String date =  scanner.next();        
        }
        if(selectedMenu == 2){
             System.out.println("Enter the dive ID : ");
            String diveId = scanner.next();
        }
        
        
        
    }
}


