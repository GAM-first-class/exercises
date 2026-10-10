
USE master;
GO
DROP DATABASE IF EXISTS AcademyDb;
GO
CREATE DATABASE AcademyDb;
GO
USE AcademyDb;
GO


CREATE TABLE dbo.Teachers
(
    TeacherId     SMALLINT       IDENTITY(1,1)  NOT NULL,
    FirstName     NVARCHAR(50)   NOT NULL,
    LastName      NVARCHAR(50)   NOT NULL,
    NationalCode  CHAR(10)       NOT NULL,
    Mobile        VARCHAR(11)    NOT NULL,
    Email         VARCHAR(100)   NULL,
    HireDate      DATE           NOT NULL  CONSTRAINT DF_Teachers_HireDate DEFAULT (CAST(GETDATE() AS DATE)),
    HourlyRate    DECIMAL(10,0)  NOT NULL,
    SupervisorId  SMALLINT       NULL,

    CONSTRAINT PK_Teachers              PRIMARY KEY (TeacherId),
    CONSTRAINT UQ_Teachers_NationalCode UNIQUE (NationalCode),
    CONSTRAINT CK_Teachers_HourlyRate   CHECK (HourlyRate > 0),
    CONSTRAINT FK_Teachers_Supervisor   FOREIGN KEY (SupervisorId) REFERENCES dbo.Teachers(TeacherId)
);
GO

CREATE TABLE dbo.Courses
(
    CourseId       SMALLINT       IDENTITY(1,1) NOT NULL,
    Title          NVARCHAR(100)  NOT NULL,
    Category       NVARCHAR(30)   NOT NULL,
    [Level]        TINYINT        NOT NULL CONSTRAINT DF_Courses_Level DEFAULT (1),
    DurationHours  SMALLINT       NOT NULL,
    Price          DECIMAL(12,0)  NOT NULL,
    TeacherId      SMALLINT       NULL,
    StartDate      DATE           NOT NULL,
    StartTime      TIME           NOT NULL,
    Capacity       TINYINT        NOT NULL CONSTRAINT DF_Courses_Capacity DEFAULT (20),
    IsActive       BIT            NOT NULL CONSTRAINT DF_Courses_IsActive DEFAULT (1),
    [Description]  NVARCHAR(MAX)  NULL,

    CONSTRAINT PK_Courses         PRIMARY KEY (CourseId),
    CONSTRAINT CK_Courses_Level   CHECK ([Level] BETWEEN 1 AND 3),
    CONSTRAINT CK_Courses_Price   CHECK (Price >= 0),
    CONSTRAINT FK_Courses_Teacher FOREIGN KEY (TeacherId) REFERENCES dbo.Teachers(TeacherId)
);
GO

CREATE TABLE dbo.Students
(
    StudentId     INT            IDENTITY(1,1) NOT NULL,
    FirstName     NVARCHAR(50)   NOT NULL,
    LastName      NVARCHAR(50)   NOT NULL,
    NationalCode  CHAR(10)       NOT NULL,
    BirthDate     DATE           NOT NULL,
    Gender        CHAR(1)        NOT NULL,
    Mobile        VARCHAR(20)    NOT NULL,
    City          NVARCHAR(30)   NULL,
    Photo         VARBINARY(MAX) NULL,
    RegisterDate  DATETIME2(0)   NOT NULL CONSTRAINT DF_Students_RegisterDate DEFAULT (SYSDATETIME()),

    CONSTRAINT PK_Students PRIMARY KEY (StudentId),
    CONSTRAINT UQ_Students_NationalCode UNIQUE (NationalCode)
);
GO


ALTER TABLE dbo.Students ADD Email VARCHAR(100) NULL;
GO

ALTER TABLE dbo.Students ADD IsActive BIT NOT NULL CONSTRAINT DF_Students_IsActive DEFAULT (1);
GO

ALTER TABLE dbo.Students ALTER COLUMN Mobile VARCHAR(11) NOT NULL;
GO

ALTER TABLE dbo.Students ADD CONSTRAINT CK_Students_Gender CHECK (Gender IN ('M','F'));
GO

ALTER TABLE dbo.Students ADD FullName AS (FirstName + N' ' + LastName);
GO


ALTER TABLE dbo.Students DROP COLUMN Photo;
GO

ALTER TABLE dbo.Teachers DROP CONSTRAINT CK_Teachers_HourlyRate;
ALTER TABLE dbo.Teachers ADD  CONSTRAINT CK_Teachers_HourlyRate CHECK (HourlyRate >= 100000);
GO

CREATE TABLE dbo.Enrollments
(
    EnrollmentId  INT              IDENTITY(1,1) NOT NULL,
    StudentId     INT              NOT NULL,
    CourseId      SMALLINT         NOT NULL,
    EnrollDate    DATETIME2(0)     NOT NULL CONSTRAINT DF_Enrollments_EnrollDate DEFAULT (SYSDATETIME()),
    PaidAmount    DECIMAL(12,0)    NOT NULL CONSTRAINT DF_Enrollments_PaidAmount DEFAULT (0),
    Score         DECIMAL(4,2)     NULL,            -- NULL = هنوز نمره ندارد
    TrackingCode  UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Enrollments_TrackingCode DEFAULT (NEWID()),

    CONSTRAINT PK_Enrollments           PRIMARY KEY (EnrollmentId),
    CONSTRAINT UQ_Enrollments_Student_Course UNIQUE (StudentId, CourseId),   -- هر دانشجو یک‌بار در هر دوره
    CONSTRAINT CK_Enrollments_Score     CHECK (Score BETWEEN 0 AND 20),
    CONSTRAINT CK_Enrollments_Paid      CHECK (PaidAmount >= 0),
    CONSTRAINT FK_Enrollments_Student   FOREIGN KEY (StudentId) REFERENCES dbo.Students(StudentId),
    CONSTRAINT FK_Enrollments_Course    FOREIGN KEY (CourseId)  REFERENCES dbo.Courses(CourseId)
);
GO