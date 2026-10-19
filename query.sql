USE AcademyDb;

-- تمرین 1
SELECT FirstName, LastName, HireDate
FROM dbo.Teachers
WHERE HireDate >= '2020-01-01'
  AND Email IS NOT NULL
ORDER BY HireDate;

-- تمرین 2
SELECT Title, Category, Capacity
FROM dbo.Courses
WHERE Category IN (N'وب', N'پایگاه داده')
  AND Capacity < 15
ORDER BY Capacity ASC;

-- تمرین 3
SELECT FullName, City
FROM dbo.Students
WHERE Gender = 'F'
  AND (City <> N'تهران' OR City IS NULL);

-- تمرین 4
SELECT Title,
       StartDate,
       DATEDIFF(DAY, CAST(GETDATE() AS DATE), StartDate) AS [روز مانده تا شروع]
FROM dbo.Courses
WHERE StartDate > CAST(GETDATE() AS DATE)
ORDER BY StartDate;

-- تمرین 5
SELECT TOP (3) WITH TIES Title, Price
FROM dbo.Courses
ORDER BY Price ASC;

-- تمرین 6
SELECT s.FullName, c.Title, c.Price
FROM dbo.Enrollments AS e
JOIN dbo.Students AS s ON s.StudentId = e.StudentId
JOIN dbo.Courses  AS c ON c.CourseId  = e.CourseId
WHERE e.PaidAmount = 0;

-- تمرین 7
SELECT c.Title AS CourseTitle,
       ISNULL(t.FirstName  + N' ' + t.LastName,  N'ندارد') AS TeacherName,
       ISNULL(sp.FirstName + N' ' + sp.LastName, N'ندارد') AS SupervisorName
FROM dbo.Courses AS c
LEFT JOIN dbo.Teachers AS t  ON t.TeacherId  = c.TeacherId
LEFT JOIN dbo.Teachers AS sp ON sp.TeacherId = t.SupervisorId;

-- تمرین 8
SELECT s.FullName, c.Title, e.Score
FROM dbo.Enrollments AS e
JOIN dbo.Students AS s ON s.StudentId = e.StudentId
JOIN dbo.Courses  AS c ON c.CourseId  = e.CourseId
WHERE s.City = N'تهران'
  AND e.Score >= 17
ORDER BY e.Score DESC;

-- تمرین 9
SELECT t.FirstName + N' ' + t.LastName AS TeacherName,
       COUNT(c.CourseId)               AS CourseCount,
       ISNULL(SUM(c.Capacity), 0)      AS TotalCapacity
FROM dbo.Teachers AS t
LEFT JOIN dbo.Courses AS c ON c.TeacherId = t.TeacherId
GROUP BY t.TeacherId, t.FirstName, t.LastName;

-- تمرین 10
SELECT City,
       COUNT(*) AS TotalStudents,
       SUM(CASE WHEN Gender = 'F' THEN 1 ELSE 0 END) AS FemaleStudents
FROM dbo.Students
WHERE City IS NOT NULL
GROUP BY City
HAVING COUNT(*) >= 3;

-- تمرین 11
SELECT s.FullName,
       SUM(c.Price) - SUM(e.PaidAmount) AS Debt
FROM dbo.Students AS s
JOIN dbo.Enrollments AS e ON e.StudentId = s.StudentId
JOIN dbo.Courses     AS c ON c.CourseId  = e.CourseId
GROUP BY s.StudentId, s.FullName
HAVING SUM(c.Price) - SUM(e.PaidAmount) > 0
ORDER BY Debt DESC;

-- تمرین 12
SELECT c.Title, COUNT(*) AS EnrollCount
FROM dbo.Courses AS c
JOIN dbo.Enrollments AS e ON e.CourseId = c.CourseId
GROUP BY c.CourseId, c.Title
HAVING COUNT(*) > (SELECT AVG(CAST(x.Cnt AS DECIMAL(10,2)))
                   FROM (SELECT COUNT(*) AS Cnt
                         FROM dbo.Enrollments
                         GROUP BY CourseId) AS x);

-- تمرین 13
SELECT s.FullName
FROM dbo.Students AS s
WHERE NOT EXISTS (SELECT 1
                  FROM dbo.Enrollments AS e
                  JOIN dbo.Courses AS c ON c.CourseId = e.CourseId
                  WHERE e.StudentId = s.StudentId
                    AND c.Category = N'وب');

-- تمرین 14
SELECT s.FullName
FROM dbo.Students AS s
JOIN dbo.Enrollments AS ea ON ea.StudentId = s.StudentId
JOIN dbo.Courses     AS ca ON ca.CourseId  = ea.CourseId
WHERE ca.Title = N'C# پیشرفته'
  AND NOT EXISTS (SELECT 1
                  FROM dbo.Enrollments AS eb
                  JOIN dbo.Courses AS cb ON cb.CourseId = eb.CourseId
                  WHERE eb.StudentId = s.StudentId
                    AND cb.Title = N'C# مقدماتی'
                    AND eb.Score >= 12);

-- تمرین 15
SELECT c.Title, s.FullName, e.Score
FROM dbo.Enrollments AS e
JOIN dbo.Courses  AS c ON c.CourseId  = e.CourseId
JOIN dbo.Students AS s ON s.StudentId = e.StudentId
WHERE e.Score = (SELECT MAX(e2.Score)
                 FROM dbo.Enrollments AS e2
                 WHERE e2.CourseId = e.CourseId);

-- تمرین 16
SELECT c.Title, s.FullName, e.Score
FROM dbo.Enrollments AS e
JOIN dbo.Courses  AS c ON c.CourseId  = e.CourseId
JOIN dbo.Students AS s ON s.StudentId = e.StudentId
WHERE e.Score > (SELECT AVG(e2.Score)
                 FROM dbo.Enrollments AS e2
                 WHERE e2.CourseId = e.CourseId);

-- تمرین 17
SELECT s.FullName
FROM dbo.Students AS s
JOIN dbo.Enrollments AS e ON e.StudentId = s.StudentId
JOIN dbo.Courses     AS c ON c.CourseId  = e.CourseId
WHERE c.Category = N'پایگاه داده'
GROUP BY s.StudentId, s.FullName
HAVING COUNT(DISTINCT c.CourseId) = (SELECT COUNT(*)
                                     FROM dbo.Courses
                                     WHERE Category = N'پایگاه داده');

-- تمرین 18
WITH CourseCounts AS
(
    SELECT c.Title, COUNT(*) AS EnrollCount
    FROM dbo.Courses AS c
    JOIN dbo.Enrollments AS e ON e.CourseId = c.CourseId
    GROUP BY c.CourseId, c.Title
),
Ranked AS
(
    SELECT Title,
           EnrollCount,
           DENSE_RANK() OVER (ORDER BY EnrollCount DESC) AS Rnk
    FROM CourseCounts
)
SELECT Title, EnrollCount
FROM Ranked
WHERE Rnk = 2;

-- تمرین 19
SELECT N'دوره پر' AS [نوع هشدار], c.Title AS [نام]
FROM dbo.Courses AS c
LEFT JOIN dbo.Enrollments AS e ON e.CourseId = c.CourseId
GROUP BY c.CourseId, c.Title, c.Capacity
HAVING COUNT(e.EnrollmentId) >= c.Capacity
UNION ALL
SELECT N'استاد بدون دوره', t.FirstName + N' ' + t.LastName
FROM dbo.Teachers AS t
WHERE NOT EXISTS (SELECT 1 FROM dbo.Courses AS c WHERE c.TeacherId = t.TeacherId)
UNION ALL
SELECT N'دانشجوی بدون ثبت‌نام', s.FullName
FROM dbo.Students AS s
WHERE NOT EXISTS (SELECT 1 FROM dbo.Enrollments AS e WHERE e.StudentId = s.StudentId);

-- تمرین 20
WITH TeacherIncome AS
(
    SELECT t.TeacherId,
           t.FirstName + N' ' + t.LastName AS TeacherName,
           SUM(e.PaidAmount)               AS TotalPaid
    FROM dbo.Teachers AS t
    JOIN dbo.Courses     AS c ON c.TeacherId = t.TeacherId
    JOIN dbo.Enrollments AS e ON e.CourseId  = c.CourseId
    GROUP BY t.TeacherId, t.FirstName, t.LastName
)
SELECT TeacherName
FROM TeacherIncome
WHERE TotalPaid > (SELECT AVG(CAST(TotalPaid AS DECIMAL(18,2)))
                   FROM TeacherIncome)
ORDER BY TotalPaid DESC;
