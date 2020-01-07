# tags.database.tml �� XML �ɕϊ�����
# perl �X�N���v�g

# ���߂����������Ȃ̂Œ���
use Jcode;

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
	$tagcontent=$';

	# shortinfo �̎擾
	$temp=$tagcontent;
	$temp=~ /\<shortinfo\>/i;
	$temp=$';
	$temp=~ /\<\/shortinfo\>/i;
	$shortinfo=$`;

	# shortinfo �̊i�[
	$tagdata{$tagname}{"shortinfo"}=&cliptext($shortinfo);


	# remarks �̎擾
	$temp=$tagcontent;
	$temp=~ /\<remarks\>/i;
	$temp=$';
	$temp=~ /\<\/remarks\>/i;
	$remarks=$`;


	# remarks �̊i�[
	$tagdata{$tagname}{"remarks"}=&cliptext($remarks);

	# example �̎擾
	$temp=$tagcontent;
	if($temp=~ /\<example\>/i)
	{
		$temp=$';
		$temp=~ /\<\/example\>/i;
		$example=$`;

		# example �̊i�[
		$tagdata{$tagname}{"example"}=&cliptext($example);
	}


	# attribs �̎擾
	$temp=$tagcontent;
	if($temp=~ /\<attribs\>/i)
	{
		$temp=$';
		$temp=~ /\<\/attribs\>/i;
		$attribscontent=$`;

		# attrib �̕���
		$no=0;
		@attribs=&taganalysis($attribscontent,"attrib");
		foreach $attribscontent (@attribs)
		{
			# attrib ���O�̎擾
			$attribscontent=~ /\<attrib name\=[\'\"]([^\'\"]+)[\'\"]/i;
			@attribnames=split(/\,/,$1);


			# shortinfo �̎擾
			$attribshortinfo="";
			$temp=$attribscontent;
			$temp=~ /\<shortinfo\>/i;
			$temp=$';
			$temp=~ /\<\/shortinfo\>/i;
			$attribshortinfo=$`;

			# required �̎擾
			$attribrequired="";
			$temp=$attribscontent;
			$temp=~ /\<required\>/i;
			$temp=$';
			$temp=~ /\<\/required\>/i;
			$attribrequired=$`;

			# format �̎擾
			$attribformat="";
			$temp=$attribscontent;
			$temp=~ /\<format\>/i;
			$temp=$';
			$temp=~ /\<\/format\>/i;
			$attribformat=$`;

			# info �̎擾
			$attribinfo="";
			$temp=$attribscontent;
			$temp=~ /\<info\>/i;
			$temp=$';
			$temp=~ /\<\/info\>/i;
			$attribinfo=$`;

	#		print "shortinfo:",$attribshortinfo,"\n";
	#		print "required:",$attribrequired,"\n";
	#		print "info:",$attribinfo,"\n";

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


sub xml
{
	my($text);
	$text = $_[0];
	$text =~ s/<ref.*?>/<ref>/g;
	$text =~ s/<br>/<br \/>/gi;
;#	$text =~ s/&/&amp;/g;
;#	$text =~ s/</&lt;/g;
;#	$text =~ s/>/&gt;/g;
;#	$text =~ s/ /&nbsp;/g;
;#	$text =~ s/\t/&nbsp;&nbsp;&nbsp;&nbsp;/g;
	$text =~ s/\'/&apos;/g;
	$text =~ s/\"/&quot;/g;
	$text =~ s/&lt;BR&gt;/<br \/>/g;
	$text =~ s/&lt;ref&gt;/<ref>/g;
	$text =~ s/&lt;\/ref&gt;/<\/ref>/g;
	$text =~ s/&lt;TT&gt;/<scenario>/g;
	$text =~ s/&lt;\/TT&gt;/<\/scenario>/g;
	return $text;
}


@h_tagdata=%tagdata;

@outdata=();

for($i=0;$i<=$#h_tagdata;$i+=2)
{
	$od = "\t<tag id=\"tag_" .$h_tagdata[$i] . "\">\n";
	$od.="\t\t<tagname>".$h_tagdata[$i]."</tagname>\n";

	$od.="\t\t<tagshortinfo>" . &xml($h_tagdata[$i+1]{"shortinfo"}) . "</tagshortinfo>\n";

	$od.="\t\t<tagremarks>" . &xml($h_tagdata[$i+1]{"remarks"}) . "</tagremarks>\n";

	if($h_tagdata[$i+1]{"example"} ne "")
	{
		$od.="\t\t<tagexample>" . &xml($h_tagdata[$i+1]{"example"}) . "</tagexample>\n";
	}

	if($h_tagdata[$i+1]{"attribs_data_0"} ne "")
	{


		@h_data=%data;

		$no=0;
		
		while(1)
		{
		
			%data=split(/__SPLIT__/,$h_tagdata[$i+1]{"attribs_data_".$no});
			
			$od.="\t\t<attr id=\"attr_".  $h_tagdata[$i] . "_" . $data{"nam__e"} ."\">\n";
			$od.="\t\t\t<attrname>" . &xml($data{"nam__e"})."</attrname>\n";
			$od.="\t\t\t<attrshortinfo>".&xml($data{"shortinfo"})."</attrshortinfo>\n";
			$od.="\t\t\t<attrrequired>".&xml($data{"required"})."</attrrequired>\n";
			$od.="\t\t\t<attrformat>".&xml($data{"format"})."</attrformat>\n";
			$od.="\t\t\t<attrinfo>" . &xml($data{"info"})."</attrinfo>\n";
			$od.="\t\t</attr>\n";
			
			$no++;
			
			last if($h_tagdata[$i+1]{"attribs_data_".$no} eq "");
		}
	}

	$od.="\t</tag>\n";

	push(@outdata,$od);
}


$od = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n";
$od .="<tdb>\n";
foreach $data (sort @outdata)
{
	$od .= $data;
}
$od .= "</tdb>\n";


Jcode::convert( \$od, "utf8");

print $od;
