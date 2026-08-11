CREATE OR REPLACE FUNCTION AvgSalesPerEmployee(emp_id INT)
RETURNS NUMERIC AS $$
DECLARE
    avg_total NUMERIC;
BEGIN
    SELECT AVG(total_price)
    INTO avg_total
    FROM sales
    WHERE employee_id = emp_id;

    RETURN COALESCE(avg_total, 0);
END;