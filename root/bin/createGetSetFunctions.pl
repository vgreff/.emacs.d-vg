#!/usr//bin/perl

$first=1;
$i=0;
$j=0;
$k=2;
while(<>)
{
    @line =split(/[ \t]+/,$_); 
    #if ($#line == 2)
    {
	chop($line[2]);		# chop return
    }
    $type=$line[1];
    $name=$line[2];
    if (substr($name,length($name) - 2,2) eq "_;")
    {
	chop($name);
	chop($name);
    }
    $name_="${name}_";
    $nameLen1=length($name) + 1;
    $namecap="\U$name\E";
    $Name=sprintf("%s%s",substr($namecap,0,1),substr($name,1));
    if (length($name) < 9)
    {
	$tab="\t";
    }
    else
    {
	$tab="";
    }
    if ($first == 1)
    {
	$class=$line[3];
	chop($class);
#	$out[$j]=sprintf("    out << obj.%s\t<<",$name);
#	$out1[$j++]=sprintf("\n    out << \"$name='\"\t%s<< obj.%s\t%s<< \"'\\n\"",$tab,$name_,$tab);
	$out1[$j++]=sprintf("\n    out << \"$name='\"\t%s<< obj.%s\t%s<< \"' \"",$tab,$name_,$tab);
	$out2[0] = sprintf("\nvoid\n%s::printTitle(ostream& out)\n{\n    out << setw(%2d) << \"$name\"",$class,$nameLen1);
	$out2[1] = sprintf("void\n%s::printLine(ostream& out)\n{\n    out << setw(%2d) << $name_ ",$class,$nameLen1);
	$def[$i++]=sprintf("    static void printTitle(ostream& out);\n");
	$def[$i++]=sprintf("    void printLine(ostream& out);\n");
    }
    #printf("/******************************************************************************/\n");
    printf("      inline const %s& %s() const ",$type, $name);
    printf("{ return %s; }\n",$name_);
    $def[$i++]=sprintf("    %s %s() const;\n",$type,$name);
    #printf("/******************************************************************************/\n");
    printf("      inline void %s(const %s& %s) ",$name,$type,$name);
    printf("{ %s=%s; }\n",$name_,$name);
    $def[$i++]=sprintf("    void %s(const %s& %sIn);\n",$name,$type,$name);
    if ($first == 0)
    {				# 
# #	$out[$j]=sprintf(" \" \"\n        << obj.%s\t<<",$name_);
# 	$out1[$j++]=sprintf("\n        << \"$name='\"\t%s<< obj.%s\t%s<< \"'\\n\"",$tab,$name_,$tab);
 	$out1[$j++]=sprintf("\n        << \"$name='\"\t%s<< obj.%s\t%s<< \"' \"",$tab,$name_,$tab);
# 	$out2[0] .= sprintf("\n        << setw(%2d) << \"$name\"",$nameLen1);
# 	$out2[$k++] = sprintf("\n        << setw(%2d) << $name_ ",$nameLen1);
    }
    else
    {
	$first=0;
    }

}

# $out[$j]=sprintf(" \"\\n\";\n");			
$out1[$j++].=sprintf("\n        << std::endl;\n");
# $out2[0].=sprintf("\n        << endl;\n}\n\n");
# $out2[$k++]=sprintf("\n        << endl;\n}\n\n");
# printf("/******************************************************************************/\n");

# $j=0;
# while($j <= $#def)
# {
#     print $def[$j++];
# }

# # $j=0;
# # while($j <= $#out)
# # {
# #     print $out[$j++];
# # }

$j=0;
while($j <= $#out1)
{
    print $out1[$j++];
}

#printf("/******************************************************************************/\n");
# print $out2[0];
# printf("/******************************************************************************/\n");

# $k=1;
# while($k <= $#out2)
# {
#     print $out2[$k++];
# }
# printf("/******************************************************************************/\n");
