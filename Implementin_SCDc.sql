ALTER TABLE DimEmployee
ADD COLUMN start_date TIMESTAMP DEFAULT current_timestamp,
ADD COLUMN end_date TIMESTAMP DEFAULT '3000-01-01',
ADD COLUMN current_flag BOOLEAN DEFAULT TRUE,
ADD COLUMN employeeHistory_ID SERIAL;

CREATE OR REPLACE FUNCTION update_dim_employee()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.Title <> NEW.Title OR OLD.Address <> NEW.Address THEN
        UPDATE DimEmployee
        SET end_date = current_timestamp,
            current_flag = FALSE
        WHERE EmployeeID = OLD.EmployeeID AND current_flag = TRUE;

        UPDATE DimEmployee
        SET Title = NEW.Title,
            Address = NEW.Address,
            start_date = current_timestamp,
            end_date = '3000-01-01',
            current_flag = TRUE
        WHERE EmployeeID = OLD.EmployeeID;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER dim_employee_update_trigger
AFTER UPDATE ON DimEmployee
FOR EACH ROW
WHEN (OLD.Title <> NEW.Title OR OLD.Address <> NEW.Address)
EXECUTE FUNCTION update_dim_employee();


--validation
UPDATE DimEmployee
SET Address = 'Paris'
WHERE EmployeeID = 5 AND current_flag = TRUE;

UPDATE DimEmployee
SET Title = 'Sales Manager'
WHERE FirstName = 'Sara' AND LastName = 'Davis' AND current_flag = TRUE;

UPDATE DimEmployee
SET BirthDate = '1965-06-20'
WHERE EmployeeID = 3 AND current_flag = TRUE;

SELECT * from dimemployee