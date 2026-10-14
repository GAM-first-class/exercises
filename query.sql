USE AcademyDb;
GO

-- تمرین 1
SELECT FirstName, LastName, HireDate, Email 
FROM Teachers WHERE Email IS NOT NULL AND HireDate > '2020-01-01'
ORDER BY HireDate ASC
GO

-- تمرین 2
SELECT Title, Category, Capacity FROM Courses 
WHERE (Category = N'وب' OR Category = N'پایگاه داده') AND Capacity > 15
ORDER BY Capacity ASC
GO

-- تمرین 3
SELECT FullName, City FROM Students
WHERE Gender = 'F' AND (City <> N'تهران' OR City IS NULL)
GO

-- تمرین 4
SELECT Title, StartDate, DATEDIFF(DAY,GETDATE(),StartDate) AS DaysToStart FROM Courses
WHERE StartDate > GETDATE()
ORDER BY DaysToStart ASC
GO

-- تمرین 5
SELECT Title, Price FROM Courses
WHERE Price IN (SELECT DISTINCT TOP 3 Price FROM Courses ORDER BY Price ASC)
ORDER BY Price ASC
GO

-- تمرین 6
SELECT s.FullName, c.Title, e.PaidAmount FROM Enrollments AS e
INNER JOIN Courses AS c ON e.CourseId = c.CourseId 
INNER JOIN Students AS s ON e.StudentId = s.StudentId
WHERE e.PaidAmount = 0
GO

-- تمرین 7
SELECT c.Title,
	ISNULL(t.FirstName + N' ' + t.LastName,N'ندارد') AS TeachersFullName,
	ISNULL(s.FirstName + N' ' + s.LastName, N'ندارد') AS SupervisorFullName
FROM Courses AS c
LEFT JOIN Teachers AS t ON c.TeacherId = t.TeacherId
LEFT JOIN Teachers AS s ON t.SupervisorId = s.TeacherId
GO

-- تمرین 8
SELECT s.FullName,c.Title,e.Score, s.City FROM Enrollments AS e
LEFT JOIN Students AS s ON e.StudentId = s.StudentId
LEFT JOIN Courses AS c ON e.CourseId = c.CourseId
WHERE s.City = N'تهران' AND e.Score >= 17
ORDER BY e.Score DESC
GO

-- تمرین 9
SELECT  t.FirstName + N' ' + t.LastName          AS FullName,
        COUNT(c.CourseId)                         AS CourseCount,
        ISNULL(SUM(CAST(c.Capacity AS INT)), 0)   AS TotalCapacity
FROM    dbo.Teachers t
        LEFT JOIN dbo.Courses c ON c.TeacherId = t.TeacherId
GROUP BY t.TeacherId, t.FirstName, t.LastName;
GO
 
-- تمرین 10
SELECT  City,
        COUNT(*)                                  AS StudentCount,
        SUM(CASE WHEN Gender = 'F' THEN 1 ELSE 0 END) AS FemaleCount
FROM    dbo.Students
WHERE   City IS NOT NULL
GROUP BY City
HAVING  COUNT(*) >= 3;
GO
 
-- تمرین 11
SELECT  s.FullName,
        SUM(c.Price - e.PaidAmount) AS Debt
FROM    dbo.Students s
        JOIN dbo.Enrollments e ON e.StudentId = s.StudentId
        JOIN dbo.Courses     c ON c.CourseId  = e.CourseId
GROUP BY s.StudentId, s.FullName
HAVING  SUM(c.Price - e.PaidAmount) > 0
ORDER BY Debt DESC;
GO
 
-- تمرین 12
WITH CourseCounts AS
(
    SELECT  c.CourseId, c.Title, COUNT(*) AS EnrollCount
    FROM    dbo.Courses c
            JOIN dbo.Enrollments e ON e.CourseId = c.CourseId
    GROUP BY c.CourseId, c.Title
)
SELECT  Title, EnrollCount
FROM    CourseCounts
WHERE   EnrollCount > (SELECT AVG(CAST(EnrollCount AS DECIMAL(10,2))) FROM CourseCounts);
GO
 
-- تمرین 13
SELECT  s.FullName
FROM    dbo.Students s
WHERE   NOT EXISTS
        (
            SELECT 1
            FROM   dbo.Enrollments e
                   JOIN dbo.Courses c ON c.CourseId = e.CourseId
            WHERE  e.StudentId = s.StudentId
              AND  c.Category  = N'وب'
        );
GO
 
-- تمرین 14
SELECT  s.FullName
FROM    dbo.Students s
WHERE   EXISTS
        (
            SELECT 1
            FROM   dbo.Enrollments e
                   JOIN dbo.Courses c ON c.CourseId = e.CourseId
            WHERE  e.StudentId = s.StudentId
              AND  c.Title = N'C# پیشرفته'
        )
  AND   NOT EXISTS
        (
            SELECT 1
            FROM   dbo.Enrollments e
                   JOIN dbo.Courses c ON c.CourseId = e.CourseId
            WHERE  e.StudentId = s.StudentId
              AND  c.Title = N'C# مقدماتی'
              AND  e.Score >= 12
        );
GO
 
-- تمرین 15
SELECT  c.Title, s.FullName, e.Score
FROM    dbo.Enrollments e
        JOIN dbo.Courses  c ON c.CourseId  = e.CourseId
        JOIN dbo.Students s ON s.StudentId = e.StudentId
WHERE   e.Score IS NOT NULL
  AND   e.Score = (SELECT MAX(e2.Score)
                   FROM   dbo.Enrollments e2
                   WHERE  e2.CourseId = e.CourseId);
GO
 
-- تمرین 16
SELECT  c.Title, s.FullName, e.Score
FROM    dbo.Enrollments e
        JOIN dbo.Courses  c ON c.CourseId  = e.CourseId
        JOIN dbo.Students s ON s.StudentId = e.StudentId
WHERE   e.Score > (SELECT AVG(e2.Score)
                   FROM   dbo.Enrollments e2
                   WHERE  e2.CourseId = e.CourseId);
GO
 
-- تمرین 17
SELECT  s.FullName
FROM    dbo.Students s
WHERE   NOT EXISTS
        (
            SELECT 1
            FROM   dbo.Courses c
            WHERE  c.Category = N'پایگاه داده'
              AND  NOT EXISTS
                   (
                       SELECT 1
                       FROM   dbo.Enrollments e
                       WHERE  e.StudentId = s.StudentId
                         AND  e.CourseId  = c.CourseId
                   )
        );
GO
 
-- تمرین 18
WITH CourseCounts AS
(
    SELECT  c.CourseId, c.Title, COUNT(*) AS EnrollCount
    FROM    dbo.Courses c
            JOIN dbo.Enrollments e ON e.CourseId = c.CourseId
    GROUP BY c.CourseId, c.Title
)
SELECT  Title, EnrollCount
FROM    CourseCounts
WHERE   EnrollCount = (SELECT MAX(EnrollCount)
                       FROM   CourseCounts
                       WHERE  EnrollCount < (SELECT MAX(EnrollCount) FROM CourseCounts));
GO
 
-- تمرین 19
SELECT  N'دوره پر شده' AS AlertType, c.Title AS Name
FROM    dbo.Courses c
WHERE   (SELECT COUNT(*) FROM dbo.Enrollments e WHERE e.CourseId = c.CourseId) >= c.Capacity
 
UNION ALL
 
SELECT  N'استاد بدون دوره', t.FirstName + N' ' + t.LastName
FROM    dbo.Teachers t
WHERE   NOT EXISTS (SELECT 1 FROM dbo.Courses c WHERE c.TeacherId = t.TeacherId)
 
UNION ALL
 
SELECT  N'دانشجوی بدون ثبت‌نام', s.FullName
FROM    dbo.Students s
WHERE   NOT EXISTS (SELECT 1 FROM dbo.Enrollments e WHERE e.StudentId = s.StudentId);
GO
 
-- تمرین 20
WITH TeacherIncome AS
(
    SELECT  t.TeacherId,
            t.FirstName + N' ' + t.LastName AS FullName,
            SUM(e.PaidAmount)               AS Income
    FROM    dbo.Teachers t
            JOIN dbo.Courses     c ON c.TeacherId = t.TeacherId
            JOIN dbo.Enrollments e ON e.CourseId  = c.CourseId
    GROUP BY t.TeacherId, t.FirstName, t.LastName
)
SELECT  FullName, Income
FROM    TeacherIncome
WHERE   Income > (SELECT AVG(Income) FROM TeacherIncome)
ORDER BY Income DESC;
GO
