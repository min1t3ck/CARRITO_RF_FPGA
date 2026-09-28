library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MAQUINA_RECEPTOR is
    Port (
        CLK       : in  STD_LOGIC;
        RESET     : in  STD_LOGIC;

        RECIBIDO  : in  STD_LOGIC_VECTOR(7 downto 0);
        CARGA     : in  STD_LOGIC;

        CANAL_0   : out STD_LOGIC_VECTOR(7 downto 0);
        CANAL_1   : out STD_LOGIC_VECTOR(7 downto 0);
        CANAL_2   : out STD_LOGIC_VECTOR(7 downto 0);
        CANAL_3   : out STD_LOGIC_VECTOR(7 downto 0)
    );
end MAQUINA_RECEPTOR;


architecture RTL of MAQUINA_RECEPTOR is

    -- ============================================================
    -- Estados de la máquina
    -- ============================================================

    type state_type is (
        ESPERA_FE,
        RECIBIR_REG_0,
        RECIBIR_REG_1,
        RECIBIR_REG_2,
        RECIBIR_REG_3,
        ESPERA_FA
    );

    signal state : state_type := ESPERA_FE;


    -- ============================================================
    -- Registros temporales
    -- ============================================================

    signal REG_0 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal REG_1 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal REG_2 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal REG_3 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');


    -- ============================================================
    -- Registros de salida
    --
    -- Estos solamente se actualizan cuando se recibe una trama
    -- completa y válida.
    -- ============================================================

    signal canal_0_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal canal_1_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal canal_2_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal canal_3_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

begin

    -- ============================================================
    -- Salidas
    -- ============================================================

    CANAL_0 <= canal_0_reg;
    CANAL_1 <= canal_1_reg;
    CANAL_2 <= canal_2_reg;
    CANAL_3 <= canal_3_reg;


    -- ============================================================
    -- MÁQUINA RECEPTORA
    -- ============================================================

    process(CLK)
    begin

        if rising_edge(CLK) then

            if RESET = '1' then

                state <= ESPERA_FE;

                -- Registros temporales
                REG_0 <= (others => '0');
                REG_1 <= (others => '0');
                REG_2 <= (others => '0');
                REG_3 <= (others => '0');

                -- Salidas
                canal_0_reg <= (others => '0');
                canal_1_reg <= (others => '0');
                canal_2_reg <= (others => '0');
                canal_3_reg <= (others => '0');

            else

                case state is


                    -- =================================================
                    -- ESPERANDO BANDERA DE INICIO FE
                    -- =================================================

                    when ESPERA_FE =>

                        if CARGA = '1' then

                            if RECIBIDO = x"FE" then

                                -- Se detectó el inicio de una nueva trama.
                                -- Los registros temporales pueden
                                -- comenzar a recibir los datos.

                                state <= RECIBIR_REG_0;

                            end if;

                        end if;


                    -- =================================================
                    -- RECIBIR REG_0
                    -- =================================================

                    when RECIBIR_REG_0 =>

                        if CARGA = '1' then

                            REG_0 <= RECIBIDO;

                            state <= RECIBIR_REG_1;

                        end if;


                    -- =================================================
                    -- RECIBIR REG_1
                    -- =================================================

                    when RECIBIR_REG_1 =>

                        if CARGA = '1' then

                            REG_1 <= RECIBIDO;

                            state <= RECIBIR_REG_2;

                        end if;


                    -- =================================================
                    -- RECIBIR REG_2
                    -- =================================================

                    when RECIBIR_REG_2 =>

                        if CARGA = '1' then

                            REG_2 <= RECIBIDO;

                            state <= RECIBIR_REG_3;

                        end if;


                    -- =================================================
                    -- RECIBIR REG_3
                    -- =================================================

                    when RECIBIR_REG_3 =>

                        if CARGA = '1' then

                            REG_3 <= RECIBIDO;

                            state <= ESPERA_FA;

                        end if;


                    -- =================================================
                    -- ESPERAR BANDERA FINAL FA
                    -- =================================================

                    when ESPERA_FA =>

                        if CARGA = '1' then

                            if RECIBIDO = x"FA" then

                                -- =====================================
                                -- TRAMA VÁLIDA
                                -- =====================================
                                --
                                -- Ahora sí copiamos los registros
                                -- temporales hacia las salidas.

                                canal_0_reg <= REG_0;
                                canal_1_reg <= REG_1;
                                canal_2_reg <= REG_2;
                                canal_3_reg <= REG_3;

                            end if;

                            -- =========================================
                            -- TRAMA TERMINADA
                            -- =========================================
                            --
                            -- Si RECIBIDO = FA:
                            --     Se actualizaron las salidas.
                            --
                            -- Si RECIBIDO != FA:
                            --     Las salidas permanecen intactas.
                            --
                            -- En ambos casos se reinicia la recepción.

                            REG_0 <= (others => '0');
                            REG_1 <= (others => '0');
                            REG_2 <= (others => '0');
                            REG_3 <= (others => '0');

                            state <= ESPERA_FE;

                        end if;

                end case;

            end if;

        end if;

    end process;

end RTL;