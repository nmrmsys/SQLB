SET LINESIZE 150
SET TRIMSPOOL ON
SET PAGESIZE 100
SET SERVEROUTPUT ON SIZE 1000000
DECLARE
    CURSOR CUR_OBJ IS
        SELECT
            'ALTER ' ||
            CASE WHEN OBJECT_TYPE = 'PACKAGE BODY' THEN
                'PACKAGE'
            ELSE
                OBJECT_TYPE
            END || ' ' || OBJECT_NAME || ' ' ||
            CASE WHEN OBJECT_TYPE = 'PACKAGE BODY' THEN
                'COMPILEBODY'
            ELSE
                'COMPILE'
            END AS COMPILE_OBJECT
            ,OBJECT_NAME
            ,OBJECT_TYPE
        FROM USER_OBJECTS
        WHERE STATUS = 'INVALID'
        ORDER BY
            OBJECT_NAME
            ,OBJECT_TYPE;
    RETRY_MAX NUMBER := 6; -- 繰り返し回数
    -- 依存関係が複雑な環境では値を大きくする必要があるかもしれない。
BEGIN
    FOR RETRY_COUNT IN 1..RETRY_MAX LOOP
        -- IF RETRY_COUNT IN (1, RETRY_MAX) THEN
            DBMS_OUTPUT.PUT_LINE('-- ' || TO_CHAR(RETRY_COUNT) || ' 回目');
        -- END IF;
        FOR REC_OBJ IN CUR_OBJ LOOP
            -- IF RETRY_COUNT IN (1, RETRY_MAX) THEN
                DBMS_OUTPUT.PUT_LINE(REC_OBJ.COMPILE_OBJECT || ';');
            -- END IF;
            BEGIN
                EXECUTE IMMEDIATE REC_OBJ.COMPILE_OBJECT;
            EXCEPTION
                WHEN OTHERS THEN
                    IF RETRY_COUNT = RETRY_MAX THEN
                        DBMS_OUTPUT.PUT_LINE('SHOW ERROR '
                            || REC_OBJ.OBJECT_TYPE || ' ' || REC_OBJ.OBJECT_NAME);
                        -- 表示された内容をsqlpusにcopy and pasteする。
                    END IF;
            END;
        END LOOP;
    END LOOP;
END;
/
SET LINESIZE 80
SET PAGESIZE 20
