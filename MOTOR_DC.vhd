library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MOTOR_DC is
    Port (
        CLK    : in  STD_LOGIC;                     -- Reloj de 100 MHz
        VALOR  : in  STD_LOGIC_VECTOR(7 downto 0);  -- Control 0x00 - 0xFF
        PWM_DC : out STD_LOGIC                      -- Salida PWM
    );
end MOTOR_DC;


architecture RTL of MOTOR_DC is

    -- ============================================================
    -- Contador PWM de 8 bits
    -- ============================================================

    signal contador_pwm : unsigned(7 downto 0) := (others => '0');

begin

    -- ============================================================
    -- CONTADOR PWM
    -- ============================================================

    process(CLK)
    begin

        if rising_edge(CLK) then

            -- El contador recorre continuamente 0 -> 255
            if contador_pwm = 255 then
                contador_pwm <= (others => '0');
            else
                contador_pwm <= contador_pwm + 1;
            end if;

        end if;

    end process;


    -- ============================================================
    -- COMPARADOR PWM
    -- ============================================================

    process(contador_pwm, VALOR)
    begin

        if contador_pwm < unsigned(VALOR) then
            PWM_DC <= '1';
        else
            PWM_DC <= '0';
        end if;

    end process;

end RTL;