with open('rtl/VM2413/envelopegenerator.vhd', 'rb') as f:
    data = f.read()

target1 = b'''                        when Finish =>\r
                            egtmp(egtmp\'high downto egtmp\'high -1) := "00";\r
                            egtmp(egtmp\'high-2 downto 0) := (others=>\'1\');\r
                    end case;'''

repl1 = b'''                        when Finish =>\r
                            egtmp(egtmp\'high downto egtmp\'high -1) := "00";\r
                            egtmp(egtmp\'high-2 downto 0) := (others=>\'1\');\r
                        when others => null;\r
                    end case;'''

target2 = b'''                            when Finish =>\r
                                null;\r
                        end case;'''

repl2 = b'''                            when Finish =>\r
                                null;\r
                            when others => null;\r
                        end case;'''

target3 = b'''                        when Finish =>\r
                            egphase := (others => \'1\');\r
                    end case;'''

repl3 = b'''                        when Finish =>\r
                            egphase := (others => \'1\');\r
                        when others => null;\r
                    end case;'''

assert target1 in data
assert target2 in data
assert target3 in data

data = data.replace(target1, repl1, 1)
data = data.replace(target2, repl2, 1)
data = data.replace(target3, repl3, 1)

with open('rtl/VM2413/envelopegenerator.vhd', 'wb') as f:
    f.write(data)

print('Successfully updated envelopegenerator.vhd with when others clauses')

