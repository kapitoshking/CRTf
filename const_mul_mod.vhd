-- ���������� ������� �� ������� ����� X �� ������ p
--	� �������������� ����������� �����������
--
-- ������: ������� �����, ������� ������, ������� ������
-- ������� ������������: �������� ������� ��������
-- ����: 13.11.2015

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.R_code_64_bit_CRT_frac_pkg.ALL;

entity const_mul_mod is
    Generic (constant proj : natural;
             constant num_mod : natural);
    Port (X	: in unsigned(mod_bc-1 downto 0);
          X_mod_p : out  unsigned(N_bc-1 downto 0));
end const_mul_mod;

architecture Behavioral of const_mul_mod is

	constant B      : natural := 4;
	constant X_bc   : natural := mod_bc;
	constant p_bc   : natural := N_i(proj);
	constant pow2_B : natural := to_integer(SHIFT_LEFT(to_unsigned(1, B+1), B));	-- ���������� ����� � ����� �������

	-- ������� ��� ���������� ���������� ������ ����� ��������� 
	function calc_dc return natural is
		variable residue : natural;
	begin
		residue := X_bc mod B;
		if (residue = 0) then
			return X_bc / B;
		else
			return X_bc / B + 1;
		end if;
	end calc_dc;
	
	-- ���������� ��������� ��������� (������ ������� ����)
	constant dc   : natural := calc_dc;							
	
	-- ���� ���������� ����� ������ ��� ������������ ������� �������� 
	type LUT_type is array (0 to dc - 1) of unsigned (p_bc - 1 downto 0);
	type array_LUT_type is array (0 to pow2_B - 1) of LUT_type;
	
	-- ������������ ������� �������� �� ������ p ������������ ����� l
	-- �� ��� ��������� ������������ ������ ��������� (2^i)
	function Tabl (l: natural; dc: natural) return LUT_type is
		variable result : LUT_type; 
		variable shift  : natural;
	begin
		for i in 0 to dc-1 loop 
			shift := B * i; 
			result(i) := resize(SHIFT_LEFT(to_unsigned(l, dc*B), shift) * bas(proj)(num_mod), p_bc);
		end loop;
		return result;
	end Tabl;
	
	-- ������������ ������� �������� Tabl ��� ���� ��������� l
	function TablOfTabl(dc: natural) return array_LUT_type is
		variable result : array_LUT_type;
	begin
		for i in 0 to pow2_B-1 loop 
			result(i) := Tabl(i, dc);
		end loop;
		return result;
	end TablOfTabl;
	
	-- ���������� ��������� �� ����� ���� � ������� layer_num
	function LayerInputSize (layer_num: natural; digit_count: natural) return natural is
		variable result : natural;
	begin
		result := digit_count;
		for i in 2 to layer_num loop
			result := (result / 2) + (result mod 2);
		end loop;
		return result;
	end LayerInputSize;
	
	-- ��������� ������� ��������� ���� layer_num � � ����� ������� ��������
	function LayerStart (layer_num: natural; digit_count: natural) return natural is
		variable result : natural;
	begin
		result := 0;
		for i in 1 to layer_num-1 loop
			result := result + LayerInputSize(i, digit_count);
		end loop;
		return result;
	end LayerStart;
	
	-- ���������� ����� - ����������� �������� �� ���������� ��������� ������� ���� (���������)
	-- � ����������� �����
	function LayersCount(digit_count: in natural) return natural is
		variable res : natural;
		variable vn  : unsigned(31 downto 0);	-- �����, ����������� ������� ���� natural
	begin
		res := 0;
		
		vn := to_unsigned(digit_count-1, 32);		-- digit_count-1 ����� ����� ������� log(2^t)
		
		-- ������� ���������� ��� � ����� vn
		while to_integer(vn) /= 0 loop
			res := res + 1;
			vn := vn srl 1;
		end loop;
		
		return res;
	end function LayersCount;
	
	-- ����� ���������� ��������� �� ���� �����, ������� ��������
	function AllLayersSize(layers_count, digit_count : in natural) return natural is
		variable res : natural;
	begin
		res := 0;
		
		-- ������������ ���������� �������� �� ���� ����� ���� �������� �������
		for ln in 1 to layers_count+1 loop
			res := res + LayerInputSize(ln, digit_count);
		end loop;
		
		return res;
	end function AllLayersSize;
	
	
	-- ���� ��������, ��������� � �����������
	
	constant LUT  : array_LUT_type := TablOfTabl(dc);		-- ������� �������� �������� �� �������
	
	constant lc : natural := LayersCount(dc);					-- ���������� �����
	
	constant als : natural := AllLayersSize(lc, dc);		-- ���������� ��������� �� ���� �����
	
	-- ������ ���������, ��������� � ����������� �� ���� �����
	-- ��������� ���������� � ��������� ����
	-- �������� ��������, ����������� ��������������� �� ������� ������� ����
	type digits_array is array (0 to als-1) of unsigned(p_bc-1 downto 0); 
	signal digits : digits_array;
	
	-- ���������� ������, ���������� ����������� �������� ������� ������ B
	signal new_X : unsigned( B * dc - 1 downto 0);
	
	
	-- ����������� ���������� ��� ���������� �������� ���� �����
	COMPONENT Add_mod_pow2
	GENERIC (proj : natural
	);
	PORT(
		A : IN  unsigned (N_i(proj)-1 downto 0);
		B : IN  unsigned (N_i(proj)-1 downto 0);          
		Sum_mod : OUT unsigned (N_i(proj)-1 downto 0)
	);
	END COMPONENT;
	
begin

	-- ����������� �������� ������� � ���������� �����������
	new_X <= resize(X, B * dc);
	
	-- ������� 1: ��������� ����� �� ����� �� B ���
	level_1: for i in 0 to dc-1 generate
	begin
		digits(i) <= LUT(to_integer(new_X(B*(i+1)-1 downto B*i)))(i);
	end generate level_1;
	
	-- ������������� ������������������ �����
	layers: for i in 1 to lc generate
   begin
		
		-- ������� 2: �������� ��������� �������� �����������
		level_2: for j in 0 to LayerInputSize(i,dc)/2 - 1  generate
		begin
			Add_mod_inst: Add_mod_pow2 
			GENERIC MAP (proj => proj
			)
			PORT MAP(
				A => digits(LayerStart(i, dc) + j),
				B => digits(LayerStart(i, dc) + LayerInputSize(i,dc) - 1 - j),
				Sum_mod => digits(LayerStart(i + 1, dc) + j)
			);
		end generate level_2;
		
		-- ������� ������������ �������� � ������ ��������� ����� �������� �� ����
		if_odd: if ((LayerInputSize(i,dc) mod 2) = 1) generate
			digits(LayerStart(i+1,dc) + LayerInputSize(i+1,dc)-1) <= digits(LayerStart(i,dc) + LayerInputSize(i,dc)/2);
		end generate if_odd;
		
	end generate layers;

	-- ������������ ��������� �������
	X_mod_p <= resize(digits(AllLayersSize(lc, dc)-1),N_bc);
	
end Behavioral;