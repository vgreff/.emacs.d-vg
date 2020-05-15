#!/usr/local/bin/perl

$first=1;
$i=0;
$j=0;
$k=2;
while(<>)
{
    @line =split(/[ \t]+/,$_); 
    if ($#line == 2)
    {
	chop($line[2]);		# chop return
    }
    $type=$line[1];
    $name=$line[2];
    if (substr($name,length($name) - 1,1) eq ";")
    {
	chop($name);
    }
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
	$out1[$j++]=sprintf("\n    out << \"$name='\"\t%s<< obj.%s\t%s<< \"'\\n\"",$tab,$name,$tab);
	$out2[0] = sprintf("\nvoid\n%s::print_title(ostream& out)\n{\n    out << setw(%2d) << \"$name\"",$class,$nameLen1);
	$out2[1] = sprintf("void\n%s::print_line(ostream& out)\n{\n    out << setw(%2d) << $name ",$class,$nameLen1);
	$def[$i++]=sprintf("    static void print_title(ostream& out);\n");
	$def[$i++]=sprintf("    void print_line(ostream& out);\n");
    }
    printf("/******************************************************************************/\n");
    printf("\ninline %s\n",$type);
    printf("%s::get_%s() const\n",$class,$name);
    printf("{\n    return %s;\n}\n\n",$name);
    $def[$i++]=sprintf("    %s get_%s() const;\n",$type,$name);
    printf("/******************************************************************************/\n");
    printf("\ninline void\n");
    printf("%s::put_%s(const %s& %s_in)\n",$class,$name,$type,$name);
    printf("{\n    %s=%s_in;\n}\n\n",$name,$name);
    $def[$i++]=sprintf("    void put_%s(const %s& %s_in);\n",$name,$type,$name);
    if ($first == 0)
    {				# 
#	$out[$j]=sprintf(" \" \"\n        << obj.%s\t<<",$name);
	$out1[$j++]=sprintf("\n        << \"$name='\"\t%s<< obj.%s\t%s<< \"'\\n\"",$tab,$name,$tab);
	$out2[0] .= sprintf("\n        << setw(%2d) << \"$name\"",$nameLen1);
	$out2[$k++] = sprintf("\n        << setw(%2d) << $name ",$nameLen1);
    }
    else
    {
	$first=0;
    }

}
$out[$j]=sprintf(" \"\\n\";\n");			
$out1[$j++].=sprintf("\n        << flush;\n");
$out2[0].=sprintf("\n        << endl;\n}\n\n");
$out2[$k++]=sprintf("\n        << endl;\n}\n\n");
printf("/******************************************************************************/\n");

$j=0;
while($j <= $#def)
{
    print $def[$j++];
}

# $j=0;
# while($j <= $#out)
# {
#     print $out[$j++];
# }

$j=0;
while($j <= $#out1)
{
    print $out1[$j++];
}

printf("/******************************************************************************/\n");
print $out2[0];
printf("/******************************************************************************/\n");

$k=1;
while($k <= $#out2)
{
    print $out2[$k++];
}
printf("/******************************************************************************/\n");
