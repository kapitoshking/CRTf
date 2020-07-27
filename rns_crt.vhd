library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.R_code_64_bit_CRT_frac_pkg.ALL;

entity rns_crt is
    Generic (constant proj : natural);
    Port (input_rns : in set_mod_type;
          output_crt : out unsigned(k*mod_bc-1 downto 0));
end rns_crt;

architecture Behavioral of rns_crt is

    signal k_mul : basis_type;
    signal num_ctr_frac : unsigned(N_bc-1 downto 0);
    
    Component const_mul_mod
        Generic (proj : natural;
                 num_mod : natural);
        Port (X : in unsigned(mod_bc-1 downto 0);
              X_mod_p : out unsigned(N_bc-1 downto 0));
    end component;
    
    Component add_mod_tree
        Generic (proj : natural);
        Port (input : in basis_type;
              output : out unsigned(N_bc-1 downto 0));
    end component;
       
begin

    mul_const : for i in 0 to k-1 generate
    begin
        k_mul_const : const_mul_mod 
            Generic map (proj => proj,
                         num_mod => i)
            Port map (X => input_rns(i),
                      X_mod_p => k_mul(i));
    end generate mul_const;
    
    tree : add_mod_tree
        Generic map (proj => proj)
        Port map (input => k_mul,
                  output => num_ctr_frac);
    
    output_crt <= resize(num_ctr_frac*M_i(proj) srl N_i(proj),output_crt'length);
    
end Behavioral;