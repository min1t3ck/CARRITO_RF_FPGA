library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity COMPARADOR_1 is
    Port (
        VALOR : in  STD_LOGIC_VECTOR(7 downto 0);
        SALIDA : out STD_LOGIC
    );
end COMPARADOR_1;


architecture RTL of COMPARADOR_1 is

begin

    process(VALOR)
    begin

        if unsigned(VALOR) > 1 then
            SALIDA <= '1';
        else
            SALIDA <= '0';
        end if;

    end process;

end RTL;