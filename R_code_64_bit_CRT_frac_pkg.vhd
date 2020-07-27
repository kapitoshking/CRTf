library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;
--[[4294967296],[4294967297],[4294967299],[4294967301]]
package R_code_64_bit_CRT_frac_pkg is

	constant count : natural := 4;
	constant mod_bc : natural := 33;
	constant num_bc : natural := 64;
    constant N_bc : natural := 163;    -- �������� ����������� ��������
    constant f : natural := 3; -- ���������� ��������
    constant k : natural := 2; -- ���������� ������� ���������
    constant t : unsigned(count-1 downto 0) := "0001"; -- ���������� ������������ ������
    type N_type is array (0 to f-1) of natural;
    type mod_type is array (0 to count-1) of unsigned(mod_bc-1 downto 0);
    type hd_type is array (0 to f-1) of unsigned(count-1 downto 0);
    type array_hd_type is array (0 to count-1) of unsigned(0 downto 0);
    type set_mod_type is array (0 to k-1) of unsigned(mod_bc-1 downto 0);
    type array_set_mod_type is array (0 to f-1) of set_mod_type;
    type array_mod_type is array (0 to f-1) of mod_type;
    type M_proj_type is array (0 to f-1) of unsigned(k*mod_bc-1 downto 0);
    type basis_type is array (0 to k-1) of unsigned(N_bc-1 downto 0);
    type array_basis_type is array (0 to f-1) of basis_type;
    constant M_work : unsigned(k*mod_bc-1 downto 0) := "010000000000000000000000000000000100000000000000000000000000000000";

    constant N_i : N_type := (98,98,98);

    constant m : mod_type := ("100000000000000000000000000000000",
                              "100000000000000000000000000000001",
                              "100000000000000000000000000000011",
                              "100000000000000000000000000000101");

    constant M_i : M_proj_type := ("010000000000000000000000000000000100000000000000000000000000000000",
                                   "010000000000000000000000000000010000000000000000000000000000000011",
                                   "010000000000000000000000000000100000000000000000000000000000001111");
                                  
    constant bas : array_basis_type := (
         ("0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111111111111111111111111111011011111100111101101010000000000","0000000000000000000000000000000000000000000000000000000000000000011111111111111111111111111111111001110100000101011100100100010001100110010010000000000000000000000"),
         ("0000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000111101111111011101001001110011111011111100001100000000000000000000","0000000000000000000000000000000000000000000000000000000000000000001111111111111111111111111111111100111010000010101110010010001000110011001001000000000000000000000"),
         ("0000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000111101111111011101001001110011111011111100001100000000000000000000","0000000000000000000000000000000000000000000000000000000000000000001111111111111111111111111111111100111010000010101110010010001000110011001001000000000000000000000")
         );

end R_code_64_bit_CRT_frac_pkg;

package body R_code_64_bit_CRT_frac_pkg is

end R_code_64_bit_CRT_frac_pkg;
