# tags.database.tml �� HTML �`���ɕϊ����Atags.html �ɏo�͂���
# perl �X�N���v�g

# ���߂����������Ȃ̂Œ���

@keywords = ();

# �܂��̓t�@�C�����݂�����܂�

open FH,"tags.database.tml";
@all=<FH>;
$all=join('',@all);


# �s���ƍs���̋󔒕������폜���A�s��A��
sub cliptext
{
	$kdata=$_[0];
	$kdata=~ s/^\s*(.+)\s*$/$1/gm;
	$kdata=~ s/\n//g;
	$kdata=~ s/\s*$//g;
	return $kdata;
}

# �^�O����
# tml �ł͓������O�̃^�O������q�ɂȂ邱�Ƃ͂Ȃ��̂�
# ����������͂͂��Ȃ�

sub taganalysis
{
	$data=$_[0];
	$tag=$_[1];
	local(@contents);
	@contents=();
	while($data =~ m/(\<$tag[^\>]+\>)/i)
	{
		$taginfo=$1;
		$data2=$';
		$data2=~ /\<\/$tag\>/;
		$content=$`;
		push(@contents,$taginfo.$content);
		$data=$';
	}
	return @contents;
}


@tags=&taganalysis($all,"tag");

foreach $tagcontent (@tags)
{
	# tag ���܂����
	$tagcontent=~ /\<tag name\=[\'\"]([^\'\"]+)[\'\"]\>/i;

	$tagname=$1;
	$tagcontent=$';  #'

	# shortinfo �̎擾
	$temp=$tagcontent;
	$temp=~ /\<shortinfo\>/i;
	$temp=$'; #'
	$temp=~ /\<\/shortinfo\>/i;
	$shortinfo=$`;

	# shortinfo �̊i�[
	$tagdata{$tagname}{"shortinfo"}=&cliptext($shortinfo);

	# group �̎擾
	$temp=$tagcontent;
	$temp=~ /\<group\>/i;
	$temp=$';
	$temp=~ /\<\/group\>/i;
	$group=$`;  #'

	# group �̊i�[
	$tagdata{$tagname}{"group"}=&cliptext($group);

	# remarks �̎擾
	$temp=$tagcontent;
	$temp=~ /\<remarks\>/i;
	$temp=$';  #'
	$temp=~ /\<\/remarks\>/i;
	$remarks=$`;


	# remarks �̊i�[
	$tagdata{$tagname}{"remarks"}=&cliptext($remarks);

	# example �̎擾
	$temp=$tagcontent;
	if($temp=~ /\<example\>/i)
	{
		$temp=$';  #'
		$temp=~ /\<\/example\>/i;
		$example=$`;

		# example �̊i�[
		$tagdata{$tagname}{"example"}=&cliptext($example);
	}


	# attribs �̎擾
	$temp=$tagcontent;
	if($temp=~ /\<attribs\>/i)
	{
		$temp=$';  #'
		$temp=~ /\<\/attribs\>/i;
		$attribscontent=$`;

		# attrib �̕���
		$no=0;
		@attribs=&taganalysis($attribscontent,"attrib");
		foreach $attribscontent (@attribs)
		{
			# attrib ���O�̎擾
			$attribscontent=~ /\<attrib name\=[\'\"]([^\'\"]+)[\'\"]/i;  #'
			@attribnames=split(/\,/,$1);


			# shortinfo �̎擾
			$attribshortinfo="";
			$temp=$attribscontent;
			$temp=~ /\<shortinfo\>/i;
			$temp=$';  #'
			$temp=~ /\<\/shortinfo\>/i;
			$attribshortinfo=$`;

			# required �̎擾
			$attribrequired="";
			$temp=$attribscontent;
			$temp=~ /\<required\>/i;
			$temp=$';  #'
			$temp=~ /\<\/required\>/i;
			$attribrequired=$`;

			# format �̎擾
			$attribformat="";
			$temp=$attribscontent;
			$temp=~ /\<format\>/i;
			$temp=$';  #'
			$temp=~ /\<\/format\>/i;
			$attribformat=$`;

			# info �̎擾
			$attribinfo="";
			$temp=$attribscontent;
			$temp=~ /\<info\>/i;
			$temp=$';  #'
			$temp=~ /\<\/info\>/i;
			$attribinfo=$`;


			# �f�[�^�̊i�[
			foreach $attribname(@attribnames)
			{

				%data=();

				$data{"shortinfo"}=
						&cliptext($attribshortinfo);

				$data{"required"}=
					&cliptext($attribrequired);

				$data{"format"}=
						&cliptext($attribformat);
				$data{"info"}=
						&cliptext($attribinfo);

				$data{"nam__e"}=$attribname;

				$tagdata{$tagname}{"attribs_data_".$no}=
					join("__SPLIT__",%data);
				$no++;
			}
		}
	}
}



# �f�[�^�̓f���o��


@data=<DATA>;
print @data;


sub conv_html
{
	$data=$_[0];
	$data=~ s/\<ref\s+tag\=[\"\']([^\"\']+)[\"\']\>/\<a class=\"jump\" href=\"\#$1\"\>/gi;
	$data=~ s/\<\/ref\>/\<\/a\>/gi;
	$data=~ s/<br>/<br \/>/gi;
	$data =~ s/<tt>(.*?)<\/tt>/<span class=\"script\">$1<\/span>/gsi;
	return $data;
}


@h_tagdata=%tagdata;

@outdata=();


@genredata=();

for($i=0;$i<=$#h_tagdata;$i+=2)
{
	$od = "";
	$od.="\n";
	$current_tag = $h_tagdata[$i];
	push @keywords, $h_tagdata[$i] . "\t" . $h_tagdata[$i] . "\t". "Tags.html" . "\t". "�^�O���t�@�����X";
	$od.="<h1><a name=\"$h_tagdata[$i]\" id=\"$h_tagdata[$i]\" class=\"targanchor\"><span class=\"b\">$h_tagdata[$i]</span> ( ".$h_tagdata[$i+1]{"shortinfo"}." )</a></h1>\n";
	$od.="<div class=\"taggenre\">".$h_tagdata[$i+1]{"group"}."</div>\n";
	$od.="<div class=\"para\"><div>";

	$gd=$h_tagdata[$i+1]{"group"}."__SPLIT__".$h_tagdata[$i]."__SPLIT__".
		$h_tagdata[$i+1]{"shortinfo"};

	push(@genredata,$gd);

	if($h_tagdata[$i+1]{"attribs_data_0"} ne "")
	{


		@h_data=%data;

		$od.="<table class=\"tagparams\" frame=\"box\" rules=\"all\" summary=\"�^�O " . $h_tagdata[$i] ." (" . $h_tagdata[$i+1]{"shortinfo"}.") �̑����̈ꗗ\">";
		$od.="<thead><tr>";
		$od.="<td>����</td><td>�K�{?</td>";
		$od.="<td>�l</td><td>����</td>";
		$od.="</tr></thead><tbody>\n";

		$no=0;
		
		while(1)
		{
			%data=split(/__SPLIT__/,$h_tagdata[$i+1]{"attribs_data_".$no});
		
			$od.="<tr>";
			$od.="<td class=\"tagattribname\"><a class=\"targanchor\" name=\"". $current_tag . "_" . $data{"nam__e"} . "\" id=\"". $current_tag . "_" . $data{"nam__e"} . "\">";
			$od.=$data{"nam__e"};
			push @keywords, $data{"nam__e"} . "\t" . $current_tag . "_" . $data{"nam__e"} . "\t" .
				"Tags.html" . "\t". "�^�O���t�@�����X-" . $current_tag;
			$od.="</a></td>";
			$od.="<td class=\"tagattribrequired\">";
			if($data{"required"} eq "yes")
			{
				$od.="<span class=\"tagrequiredattrib\">";
			}
			$od.=$data{"required"};
			if($data{"required"} eq "yes")
			{
				$od.="</span>";
			}
			$od.="</td>";
			$od.="<td class=\"tagattribformat\">";
			$od.=$data{"format"};
			$od.="</td>";
			$od.="<td class=\"tagattribdesc\">";
			$od.=&conv_html($data{"info"});
			$od.="</td>";
			$od.="</tr>\n";

			$no++;
			
			last if($h_tagdata[$i+1]{"attribs_data_".$no} eq "");
		}
		$od.="</tbody></table>";
	}
	
	$od.= "<div class=\"tagremarks\">". &conv_html($h_tagdata[$i+1]{"remarks"}) ."</div>\n";


	if($h_tagdata[$i+1]{"example"} ne "")
	{
		$od.="<div class=\"tagexample\"><code class=\"bq\"><span class=\"weak\">��:</span><br />\n";
		$od.=&conv_html($h_tagdata[$i+1]{"example"})."\n";
		$od.="</code></div>\n";
	}

	$od.="<div class=\"toindex\"><a class=\"jump\" href=\"#genre\"><span class=\"toindexanchor\">�W�������E�^�O�ꗗ�ɖ߂�</span></a></div>";
	$od.="</div></div>\n";

	push(@outdata,$od);
}

print "<div class=\"para\"><div>";

$genre="";
$phase=0;
foreach $data( sort @genredata)
{
	@dat=split(/__SPLIT__/,$data);
	if($genre ne $dat[0])
	{
		print "</tbody></table>\n" if $genre ne "";
		$genre=$dat[0];
		print "<br />\n<div class=\"taggenrehead\">$genre</div><br />\n";
		print "<table class=\"taglist\" summary=\"$genre �^�O�ꗗ\"><tbody>\n";
	}
	print "<tr>";
	if($phase)
	{
		print "<td class=\"taglistodd\">";
	}
	else
	{
		print "<td class=\"taglisteven\">";
	}
	print "<span class=\"taglistlink\"><a class=\"jump\" href=\"#$dat[1]\">$dat[1]</a></span>";
	print "</td>";
	if($phase)
	{
		print "<td class=\"taglistodd\">";
	}
	else
	{
		print "<td class=\"taglisteven\">";
	}
	$phase ^=1;
	print "( $dat[2] )";
	print "</td></tr>\n";
}

print "</tbody></table><br /><br /></div></div>\n";

foreach $data (sort @outdata)
{
	print $data;
}


print <<EOF;
	<script type="text/javascript" charset="Shift_JIS" src="documentid.js" ></script>
	<script type="text/javascript" charset="Shift_JIS" src="postcontent.js" ></script>
EOF


print "</body></html>\n";

push keywords, "�^�O�̊T�v\ttag_overview\tTags.html\t�^�O���t�@�����X";
push keywords, "�R�}���h�s\ttag_command\tTags.html\t�^�O���t�@�����X";
push keywords, "cond ����\ttag_cond_attrib\tTags.html\t�^�O���t�@�����X";
push keywords, "�^�O���t�@�����X\ttags\tTags.html\t�^�O���t�@�����X";

open OH, ">keys.txt";
print OH join("\n", @keywords);
print OH "\n";


__DATA__
<?xml version="1.0" encoding="Shift_JIS"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html  xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=Shift_JIS" />
	<title>�^�O���t�@�����X</title>
	<meta name="author" content="W.Dee" />
	<meta http-equiv="Content-Style-Type" content="text/css" />
	<meta http-equiv="Content-Script-Type" content="text/javascript" />
	<link href="browser.css" type="text/css" rel="stylesheet" title="�g���g���֘A���t�@�����X�p�W���X�^�C��" />
	<link href="mailto:dee@kikyou.info" rev="Made" />
	<link href="index.html" target="_top" rel="Start" title="�g�b�v�y�[�W" />
</head>
<body>

<h1><a name="tags" id="tags">�^�O���t�@�����X</a></h1>
<div class="para"><div>�@KAG �Ŏg�p�\�ȃ^�O�̃��t�@�����X�ł��B</div></div>
<h1><a name="tag_overview" id="tag_overview">�^�O�̊T�v</a></h1>
<div class="para"><div>
�@�^�O�́A[ ] �̊ԂɈ͂܂ꂽ���̂ł��B��{�I�ɔ��p�p���������ŋL�q���܂��B
�@<span class="script">[</span> �̎��ɂ����Ƀ^�O���������܂��B���Ƃ��΁Atrans
�Ƃ����^�O�ł���� <span class="script">[trans</span> �ƂȂ�܂��B<br />
�@�^�O�ɂ́A�^�O�̃I�v�V�������w�肷�邽�߂ɑ����Ƃ������̂�����܂��B�Ȃɂ��������w�肵�Ȃ��Ă����ꍇ�́A�^�O���̂��Ƃ� <span class="script">]</span> �������ă^�O�͏I���ł��B���Ƃ���
<span class="script">[ct]</span>
�ƂȂ�܂��B<br />
�@�������w�肷��ꍇ�́A�^�O���̂��Ƃ�A�O�̑����̂��Ƃɂ͕K�����p�X�y�[�X���󂯂āA�������������܂��B�������̌�ɂ�
= �������A���̌�ɑ����̒l�������܂��B���ׂĂ̑������������� <span class="script">]</span>
�Ń^�O����܂��B<br />
�@���Ƃ��΁Atrans �^�O�� time �Ƃ������������������ꍇ�́A<span class="script">[trans time=0]</span> �Ƃ��܂��B�܂��A����� rule=trans vague=1 �Ƃ������������������ꍇ��
<span class="script">[trans time=0 rule=trans vague=1]</span> �Ƃ��܂��B<br />
�@�����̒l�� "" �ň͂�ł��͂܂Ȃ��Ă������ł��B���Ƃ��΁A<span class="script">[trans time="0"]</span>�� <span class="script">[trans time=0]</span>
�͓����ł��B�������A�����̒l�ɋ󔒂��܂ނ悤�ȏꍇ�́A"" �ň͂܂Ȃ���΂Ȃ�܂���B���Ƃ��΁A<span class="script">[font face="�l�r �o�S�V�b�N"]</span> �ł��B<br />
�@�܂��A�����̒l�ɑ΂��A&amp; ���ŏ��ɂ���ƁA���̌�ɏ��������̂�
TJS ���Ƃ��ĕ]�����A���̌��ʂ𑮐��̒l�Ƃ��܂��B���Ƃ��΁A<span class="script">[trans time=&amp;f.clearTime]</span> �Ƃ���ƁA<span class="script">f.clearTime</span> �Ƃ����ϐ��̓��e���Atime
�����̒l�ƂȂ�܂��B<br />
�@�����̒l���ȗ������ (�����̂��� '=' �ȍ~�������Ȃ���)�Atrue �Ƃ��������̒l���w�肳�ꂽ�ƌ��Ȃ���܂��B���Ƃ��΁A<span class="script">[playse loop storage="shock.wav"]</span> �́Aloop �����̒l���ȗ�����Ă��܂����A����� <span class="script">[playse loop=true storage="shock.wav"]</span> �Ɠ����Ӗ��ɂȂ�܂��B<br />
</div></div>
<h1><a name="tag_command" id="tag_command">�R�}���h�s</a></h1>
<div class="para"><div>
�@�R�}���h�s�́A@ �Ŏn�܂�A���̎��Ƀ^�O���Ƒ������L�q������̂ł��B<br />
�@��̍s�ɂ͈�̃^�O�݂̂��������Ƃ��ł��܂��B<br />
�@�ȉ��̓�̍s�͓����ɂȂ�܂��B<br />
<br />
<div class="bq">
[trans time=0 rule=trans vague=1]<br />
@trans time=0 rule=trans vague=1<br />
</div>
</div>
</div>
<h1><a name="tag_cond_attrib" id="tag_cond_attrib">cond ����</a></h1>
<div class="para"><div>
�@macro endmacro if else elsif endif ignore endignore iscript endscript �̃^�O���̂����A���ׂẴ^�O�� cond ����������܂��B<br />
�@cond �����ɂ� TJS�� ���w�肵�A���̎���]���������ʂ��^�̎��݂̂ɂ��̃^�O�����s����܂��B�U�̎��̓^�O�͎��s����܂���B<br />
<br />
�� :<br />
<div class="bq">
[l cond=f.noskip]<br />
; �� f.noskip ���^�̎��̂� l �^�O�����s<br />
</div>
</div>
</div>

<h1><a name="genre" id="genre" class="targanchor">�W�������E�^�O�ꗗ</a></h1>


