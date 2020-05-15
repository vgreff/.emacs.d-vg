#!/usr/local/bin/perl
#
# FILE: %M%
#
# VERSION: %I%
#    
# CREATED: April 21, 1995
#
# MODIFIED:     
#
# PROGRAMMER: Vincent B. Greff
#
# AUTHOR: Citadel Investment Group
#
# DESCRIPTION:
#
# Copyright %G% Citadel Investment Group
#
#
# sccsId = "%W%	%E% %U%"

# usage:
# 1st line = dbname tableAlias className
# sp_help for the table

$skip=0;
$state=-1;
$colNum=0;
while(<>)
{
    if ($state == -1)
    {
	$state++;
	chop;
	@line=split(/[ \t]+/,$_);
	$dbName=$line[0];
	$tableAlias=$line[1];
	$class=$line[2];
	next;
    }
    elsif ($skip > 0)
    {
	$skip--;
	next;
    }
    elsif (/Name                           Owner                          Type/ &&
	   ($state == 0))
    {
	$skip = 1;
	$state++;
    }
    elsif ($state == 1)
    {
	$skip = 5;
	$state++;
	@line=split(/[ \t]+/,$_);
	$tableName=$line[1];
#	printf("$tableName\n");
    }
    elsif (/Column_name +Type +Length/ &&
	   ($state == 2))
    {
	$skip = 1;
	$state++;
    }
    elsif (($state == 3) && /^\n/)
    {
	$state++;
	$skip=2;
    }
    elsif ($state == 3)
    {
	@line=split(/[ \t]+/,$_);
	$colType[$colNum]=$line[2];
	$colQuote[$colNum]="";
	$colExtractFunc[$colNum]="";
	if ($colType[$colNum] =~/char/i)
	{
	    $colTypeC[$colNum]="RWCString";
	    $colQuote[$colNum]="'";
	}
	elsif ($colType[$colNum] =~/date/i)
	{
	    $colTypeC[$colNum]="RWDate";
	    $colQuote[$colNum]="'";
	    $colExtractFunc[$colNum]=".asString()";
	}
	elsif ($colType[$colNum] =~/smallint/i)
	{
	    $colTypeC[$colNum]="short";
	}
	elsif (($colType[$colNum] =~/tinyint/i) ||
	       ($colType[$colNum] =~/bool/i))
	{
	    $colTypeC[$colNum]="TinyInt";
	}
	elsif ($colType[$colNum] =~/float/i)
	{
	    $colTypeC[$colNum]="double";
	}
	elsif ($colType[$colNum] =~/U_KEY/i)
	{
	    $colTypeC[$colNum]="U_KEY";
	}
	elsif ($colType[$colNum] =~/int/i)
	{
	    $colTypeC[$colNum]="int";
	}
	$colName[$colNum]=$line[1];
	($colNameC[$colNum]=$colName[$colNum])=~s/_([a-z])/\u\1/g;
#	printf("$colName[$colNum] $colType[$colNum]\n");
	$colNum++;
    }
    elsif (($state == 4) && / clustered/)
    {
	$state++;
	chop;
	$indexes=substr($_,80,length($_)-80);
	@indexCol=split(/,[ \t]+/,$indexes);
	$indexCol[$#indexCol]=~s/ //g;
	$indexCol[$#indexCol]=~s/\t//g;
	$indexCol[0]=~s/ //g;
	$indexCol[0]=~s/\t//g;
# 	printf("$#indexCol $indexCol[0] $indexCol[1]\n");
   }
}

# compute index pointer
for($i=0;$i <= $#indexCol;$i++)
{
    for($j=0;$j < $colNum;$j++)
    {
#	printf("'$indexCol[$i]' '$colName[$j]'\n");
	if ($indexCol[$i] eq $colName[$j])
	{
	    $indexColPos[$i] = $j;
	    break;
	}
    }
}

$num=0;
for($i=0;$i < $colNum;$i++)
{
    $colNoIndex[$num++]=$i;
    for($j=0;$j <= $#indexCol;$j++)
    {
	if ($i == $indexColPos[$j])
	{
	    $num--;
	    break;
	}
    }
}


# print C++ declarations

printf("public:\n    enum ${class}Status {NewRecord,ExistedRecord,ModifiedRecord};\nprivate:\n    ${class}Status state;\n");
for($i=0;$i < $colNum;$i++)
{
    printf("    $colTypeC[$i] $colNameC[$i];\n");
}


printf("/******************************************************************************/\n\n");
printf("    %s(ITDbms4RW& db);\n\n",$class);
printf("    void loadRecordFromDb(ITDbms4RW& db);\n");
printf("    void insertRecordIntoDb(ITDbms4RW& db);\n");
printf("    void updateRecordIntoDb(ITDbms4RW& db);\n");
printf("    int  writeRecordIntoDb(ITDbms4RW& db);\n");
printf("    void saveRecordIntoDb(ITDbms4RW& db);\n");

printf("\n    // in container class\n    void loadFromDb(ITDbms4RW& db);\n");


# print constructor function

printf("\n/******************************************************************************/\n");
printf("\n$class\::$class(ITDbms4RW& db)\n    : state(ExistedRecord)\n{\n    loadRecordFromDb(db);\n");
printf("}\n");


# print loadRecordFromDb function

printf("\n/******************************************************************************/\n");
printf("\nvoid\n");
printf("%s::loadRecordFromDb(ITDbms4RW& db)\n{\n",$class);

for($i=0;$i <= $#colName;$i++)
{
    printf("    db.getAndCheckColumnNTB($colNameC[$i],\"$colName[$i]\");\n");
}
printf("}\n\n");
			    

# print insertRecordIntoDb function

printf("/******************************************************************************/\n");
printf("\nvoid\n");
printf("%s::insertRecordIntoDb(ITDbms4RW& db)\n",$class);
printf("{\n    db.SetDbError(ITDB_SUCCESS);\n");

&printInsertSQL();
&printGetResultNORESULTS();
printf("}\n\n");


# print updateDb function

printf("/******************************************************************************/\n");
printf("\nvoid\n");
printf("%s::updateRecordIntoDb(ITDbms4RW& db)\n",$class);
printf("{\n    db.SetDbError(ITDB_SUCCESS);\n");
&printUpdateSQL();
&printGetResultNORESULTS();
printf("}\n\n");


# print writeRecordIntoDb function

printf("/******************************************************************************/\n");
printf("\nint\n");
printf("%s::writeRecordIntoDb(ITDbms4RW& db)\n",$class);
printf("{\n    if (state == NewRecord)\n");
printf("    {\n");
printf("	insertRecordIntoDb(db);\n");
printf("	return 1;\n");
printf("    }\n");
printf("    else if (state == ModifiedRecord)\n");
printf("    {\n");
printf("	updateRecordIntoDb(db);\n");
printf("	return 2;\n");
printf("    }\n");
printf("    return 0;\n");
printf("}\n\n");


# print saveRecordIntoDb function

printf("/******************************************************************************/\n");
printf("\nvoid\n");
printf("%s::saveRecordIntoDb(ITDbms4RW& db)\n",$class);
printf("{\n    db.SetDbError(ITDB_SUCCESS);\n");
printf("    db << \"if exists (select * from %s..%s \\n\";\n",$dbName,$tableName);

for($i=0;$i <= $#indexColPos;$i++)
{
    if ($i == 0)
    {
	$keyword="where";
    }
    else
    {
	$keyword="  and";
    }
    if ($i == $#indexColPos)
    {
	$comma=")";
    }
    $j=$indexColPos[$i];
    printf("    db << \"           %s ",$keyword);
    printf("$colName[$j] = $colQuote[$j]\" << $colNameC[$j]$colExtractFunc[$j] << \"$colQuote[$j]$comma \\n\";\n");
}
printf("\n");
&printUpdateSQL();
printf("\n    db << \"else \\n\";\n\n"); 
&printInsertSQL();

&printGetResultNORESULTS();
printf("}\n\n");


# print loadFromDb function

printf("/******************************************************************************/\n");
printf("\nvoid\n");
printf("%s::loadFromDb(ITDbms4RW& db)\n",$class);
printf("{\n    db.SetDbError(ITDB_SUCCESS);\n");
printf("    db << \"select \\n\";\n");

$comma=",";
for($i=0;$i <= $#colName;$i++)
{
    if ($i == $#colName)
    {
	$comma="";
    }
    printf("    db << \"             %s.$colName[$i]$comma \\n\";\n",$tableAlias);
}

printf("    db << \"from %s..%s %s \\n\";\n",$dbName,$tableName,$tableAlias);
for($i=0;$i <= $#indexColPos;$i++)
{
    if ($i == 0)
    {
	$keyword="where";
    }
    else
    {
	$keyword="  and";
    }
    $j=$indexColPos[$i];
    printf("    db << \" %s ",$keyword);
    printf("%s.$colName[$j] = $colQuote[$j]\" << $colNameC[$j]$colExtractFunc[$j] << \"$colQuote[$j]$comma \\n\";\n",$tableAlias);
}

printf("\n    while(db.GetResults() == IT_REGULAR_ROW )\n");
printf("    {\n 	insert(new %s(db));\n    }\n",$class);
printf("    if(db.GetDbError() != ITDB_SUCCESS)\n");
printf("    {\n");
printf("	cerr << \"D/B error in %s::loadFromDb()\"\n",$class);
printf("	     << \", GetDbError() = \"\n");
printf("	     << db.GetDbError() << endl;\n");
printf("    }\n");
printf("    cout << \".entries=\"\n	 << entries() << endl;\n");
printf("}\n\n");



printf("/******************************************************************************/\n");



sub printGetResultNORESULTS
{
    printf("\n    while(db.GetResults() != IT_NORESULTS );\n");
    printf("    if(db.GetDbError() != ITDB_SUCCESS)\n");
    printf("    {\n");
    printf("	cerr << \"D/B error in %s::insertRecordIntoDb()\"\n",$class);
    printf("	     << \", GetDbError() = \"\n");
    printf("	     << db.GetDbError() << endl;\n");
    printf("	cerr << *this;\n");
    printf("    }\n");
}

sub printUpdateSQL
{
    printf("    db << \"update %s..%s set \\n\";\n",$dbName,$tableName);

    $comma=",";
    for($i=0;$i <= $#colNoIndex;$i++)
    {
	if ($i == $#colNoIndex)
	{
	    $comma="";
	}
	$j=$colNoIndex[$i];
	printf("    db << \"       $colName[$j] = $colQuote[$j]\" << $colNameC[$j]$colExtractFunc[$j] << \"$colQuote[$j]$comma \\n\";\n");
    }
    for($i=0;$i <= $#indexColPos;$i++)
    {
	if ($i == 0)
	{
	    $keyword="where";
	}
	else
	{
	    $keyword="  and";
	}
	$j=$indexColPos[$i];
	printf("    db << \"  %s ",$keyword);
	printf("$colName[$j] = $colQuote[$j]\" << $colNameC[$j]$colExtractFunc[$j] << \"$colQuote[$j]$comma \\n\";\n");
    }
}


sub printInsertSQL
{
    printf("    db << \"insert into %s..%s \\n\";\n",$dbName,$tableName);
    printf("    db << \"            (  \\n\";\n");
    
    $comma=",";
    for($i=0;$i <= $#colName;$i++)
    {
	if ($i == $#colName)
	{
	    $comma="";
	}
	printf("    db << \"             $colName[$i]$comma \\n\";\n");
    }
    
    printf("    db << \"            )  \\n\";\n");
    printf("    db << \"      values(\"; \n");
    $comma=",";
    for($i=0;$i <= $#colName;$i++)
    {
	if ($i == $#colName)
	{
	    $comma="";
	}
	printf("    db << ");
	if ($colQuote[$i] eq "'")
	{
	    printf("\"$colQuote[$i]\" << ");
	}
	printf("$colNameC[$i]$colExtractFunc[$i] << \"$colQuote[$i]$comma \";\n");
    }
    printf("    db << \"           )\\n\";\n");
}

