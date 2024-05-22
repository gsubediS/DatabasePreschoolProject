

CREATE TABLE Students(
studentID int,
studentFirstName varchar(60),
studentLastName varchar(60),
age int,
sex varchar(60),
bluebook boolean,
primary key (studentID)
);

INSERT INTO Students(studentID,studentFirstName,studentLastName,age,sex,bluebook) VALUES
('1001','Ivy','West','3','F',TRUE),
('1002','Karter','Daughtler','3','M',TRUE),
('1003','Luna','Brown','3','F',TRUE),
('1004','Quinn','Mitchell','3','M',TRUE),
('1005','Callie', 'Moore','5','F',TRUE),
('1006','Reese','Raven','5','F',TRUE),
('1007','Christian','June','5','M',TRUE),
('1008','Ezekiel', 'Bolt','5','M',TRUE);

CREATE TABLE Parents(
parentID int,
parentFirstName varchar(60),
parentLastName varchar(60),
studentID int,
parentPhoneNumber varchar(60),
Restriction boolean,
parentNumber int,
primary key (parentID),
foreign key (studentID) REFERENCES Students(studentID)
);


INSERT INTO Parents(parentID,parentNumber,parentFirstName,parentLastName,studentID,parentPhoneNumber,Restriction) VALUES
    ('1','1','Samantha','West','1001','6459449531',FALSE),
    ('2','2','Jason', 'West','1001','2010939687',TRUE),
    ('3','1','Leah', 'Daughtler','1002','9028780390',FALSE),
    ('4','2','Skylar', 'Daughtler','1002','7358484397',FALSE),
    ('5','1','Eva', 'Brown','1003','2629755404',FALSE),
    ('6','2','Theodore','Brown','1003','6592726829',FALSE),
    ('7','1','Mila', 'Mitchell','1004','2248440137',FALSE),
    ('8','1','Jonah','Moore','1005','4861148175',FALSE),
    ('9','2','Londyn', 'Moore','1005','5992033476',FALSE),
    ('10','1','Renae', 'Raven','1006','9739601519',FALSE),
    ('11','2','Camden', 'Raven','1006','9299140537',FALSE),
    ('12','1','Nicolas', 'June','1007','8954302064',FALSE),
    ('13','2','Julia', 'June','1007','878286268',FALSE),
    ('14','1','Victor','Bolt','1008','3467907517',FALSE),
    ('15','2','Ember', 'Bolt','1008','7709674501',FALSE);
    
CREATE TABLE Staff(
staffID int,
staffFirstName varchar(60),
staffLastName varchar(60),
staffPosition varchar(60),
eduLevel varchar(60),
staffClass varchar(60),
primary key (staffID)
);

INSERT INTO Staff(staffID,staffFirstName,staffLastName,staffPosition,eduLevel,staffClass) VALUES
('01','Gunther','Smith','Aide','Masters','3'),
('02','Rachel','Green','Aide','Bachelors','5'),
('03','Monica','Geller','Lead','Masters','3'),
('04','Chandler','Bing','Aide','Bachelors','5'),
('05','Joey','Tribianni','Aide','HighSchool','3'),
('06','Pheobe','Buffay','Lead','Masters','5'),
('07','Ross','Geller','Lead','PhD','5'),
('08','Mike','Hannigan','Lead','Bachelors','3');



CREATE TABLE Classrooms(
classroomID int PRIMARY KEY,
class varchar(60),
ageGroup int,
section varchar(1),
leadTeacherID INT,
teacherAideID INT,
classCapacity int,
FOREIGN KEY (leadTeacherID) REFERENCES Staff(staffID),
FOREIGN KEY (teacherAideID) REFERENCES Staff(staffID)
);

INSERT INTO Classrooms(classroomID,class,ageGroup,section,leadTeacherID,teacherAideID) values
('301','Threes','3','A','08','01'),
('302','Threes','3','B','03','05'),
('501','Fives','5','A','07','04'),
('502','Fives','5','B','06','02');


#view tables
SELECT * FROM Students;
SELECT * FROM Parents;
SELECT * FROM Staff;
SELECT * FROM Classrooms;



#View Student's Parents
SELECT 
    Students.studentID,
    Students.studentFirstName,
    Students.studentLastName,
    ParentOne.parentFirstName as parentOneFirstName,
    ParentOne.parentLastName as parentOneLastName,
    ParentOne.Restriction,
    ParentTwo.parentFirstName as parentTwoFirstName,
    ParentTwo.parentLastName as parentTwoLastName,
    ParentTwo.Restriction
FROM Students
LEFT JOIN
Parents as ParentOne
ON Students.studentID = ParentOne.studentID
AND ParentOne.parentNumber = 1
LEFT JOIN
Parents as ParentTwo
ON Students.studentID = ParentTwo.studentID
AND ParentTwo.parentNumber = 2;



#View the Staff for each class
	
SELECT 
	Classrooms.classroomID,
    Staff1.staffFirstName as LeadFirstName,
	Staff1.staffLastName as LeadLastName,
    Staff2.staffFirstName as AideFirstName,
    Staff2.staffLastName as AideLastName
FROM Classrooms
INNER JOIN
Staff as Staff1 on Staff1.staffID = Classrooms.leadTeacherID
INNER JOIN
Staff as Staff2 on Staff2.staffID = Classrooms.teacherAideID;



#Classroom assignment  

CREATE TABLE classAssignment(
	studentId int primary key,
    classroomID int
    );


#Main query for class assignment based on age and gender
    
INSERT INTO classAssignment(studentId, classroomID)
SELECT Students.studentId, Classrooms.classroomID
FROM (
	SELECT studentId, age, ROW_NUMBER() OVER (ORDER BY studentId) AS row_num
    FROM Students
    WHERE sex = 'F'
) Students
JOIN(
	SELECT classroomID, ageGroup, ROW_NUMBER() OVER (ORDER BY classroomID) AS row_num
    FROM Classrooms
    ) Classrooms
    ON Students.row_num = Classrooms.row_num AND Students.age = Classrooms.ageGroup
    
UNION
    
SELECT Students.studentID, Classrooms.classroomID
FROM (
	SELECT studentID, age, ROW_NUMBER() OVER (ORDER BY studentID) AS row_num
    FROM Students
    WHERE sex = 'M'
) Students
JOIN(
	SELECT classroomID, ageGroup, ROW_NUMBER() OVER (ORDER BY classroomID) AS row_num
    FROM Classrooms
    ) Classrooms
    ON Students.row_num = Classrooms.row_num AND Students.age = Classrooms.ageGroup;
	
    
#view classAssignment table

SELECT * FROM classAssignment;

	

#View Children in their classes based on classAssignment

SELECT 
    Classrooms.classroomID,
    Students.studentFirstName,
    Students.studentLastName,
    Students.sex,
    Students.age,
    Students.bluebook,
    Classrooms.class,
    Classrooms.ageGroup,
    Classrooms.section,
    Staff1.staffFirstName as LeadFirstName,
    Staff1.staffLastName as LeadLastName,
    Staff2.staffFirstName as AideFirstName,
    Staff2.staffLastName as AideLastName
FROM classAssignment
JOIN 
Students on Students.studentID = classAssignment.studentID
JOIN
Classrooms on Classrooms.classroomID = classAssignment.classroomID
JOIN
Staff as Staff1 on Staff1.staffID = Classrooms.leadTeacherID
JOIN
Staff as Staff2 on Staff2.staffID = Classrooms.teacherAideID
ORDER BY Classrooms.classroomID;














