# $Id$

##
# this test checks the DOM element and attribute interface of XML::LibXML

use Test;

BEGIN { plan tests => 55 };
use XML::LibXML;

my $foo       = "foo";
my $bar       = "bar";
my $nsURI     = "http://foo";
my $prefix    = "x";
my $attname1  = "A";
my $attvalue1 = "a";
my $attname2  = "B";
my $attvalue2 = "b";
my $attname3  = "C";

print "# 1. bound node\n";
{
    my $doc = XML::LibXML::Document->new();
    my $elem = $doc->createElement( $foo );
    ok($elem);
    ok($elem->tagName, $foo);
    
    $elem->setAttribute( $attname1, $attvalue1 );
    ok( $elem->hasAttribute($attname1) );
    ok( $elem->getAttribute($attname1), $attvalue1);

    my $attr = $elem->getAttributeNode($attname1);
    ok($attr);
    ok($attr->name, $attname1);
    ok($attr->value, $attvalue1);

    $elem->setAttribute( $attname1, $attvalue2 );
    ok($elem->getAttribute($attname1), $attvalue2);
    ok($attr->value, $attvalue2);

    my $attr2 = $doc->createAttribute($attname2, $attvalue1);
    ok($attr2);

    $elem->setAttributeNode($attr2);
    ok($elem->hasAttribute($attname2) );
    ok($elem->getAttribute($attname2),$attvalue1);

    my $tattr = $elem->getAttributeNode($attname2);
    ok($tattr->isSameNode($attr2));

    $elem->setAttribute($attname2, "");    
    ok($elem->hasAttribute($attname2) );
    ok($elem->getAttribute($attname2), "");
    
    $elem->setAttribute($attname3, "");    
    ok($elem->hasAttribute($attname3) );
    ok($elem->getAttribute($attname3), "");

    print "# 1.1 Namespaced Attributes\n";

    $elem->setAttributeNS( $nsURI, $prefix . ":". $foo, $attvalue2 );
    ok( $elem->hasAttributeNS( $nsURI, $foo ) );
    # warn $elem->toString() , "\n";
    $tattr = $elem->getAttributeNodeNS( $nsURI, $foo );
    ok($tattr);
    ok($tattr->name, $foo);
    ok($tattr->nodeName, $prefix .":".$foo);
    ok($tattr->value, $attvalue2 );

    $elem->removeAttributeNode( $tattr );
    ok( !$elem->hasAttributeNS($nsURI, $foo) );

    # node based functions
    my $e2 = $doc->createElement($foo);
    $doc->setDocumentElement($e2);
    my $nsAttr = $doc->createAttributeNS( $nsURI.".x", $prefix . ":". $foo, $bar);
    ok( $nsAttr );
    $elem->setAttributeNodeNS($nsAttr);
    ok( $elem->hasAttributeNS($nsURI.".x", $foo) );    
    $elem->removeAttributeNS( $nsURI.".x", $foo);
    ok( !$elem->hasAttributeNS($nsURI.".x", $foo) );

    $elem->setAttributeNS( $nsURI, $prefix . ":". $attname1, $attvalue2 );

    $elem->removeAttributeNS("",$attname1);
    ok( $elem->hasAttribute($attname1) );
    ok( $elem->hasAttributeNS($nsURI,$attname1) );
} 

print "# 2. unbound node\n";
{
    my $elem = XML::LibXML::Element->new($foo);
    ok($elem);
    ok($elem->tagName, $foo);

    $elem->setAttribute( $attname1, $attvalue1 );
    ok( $elem->hasAttribute($attname1) );
    ok( $elem->getAttribute($attname1), $attvalue1);

    my $attr = $elem->getAttributeNode($attname1);
    ok($attr);
    ok($attr->name, $attname1);
    ok($attr->value, $attvalue1);

    $elem->setAttributeNS( $nsURI, $prefix . ":". $foo, $attvalue2 );
    ok( $elem->hasAttributeNS( $nsURI, $foo ) );
    # warn $elem->toString() , "\n";
    my $tattr = $elem->getAttributeNodeNS( $nsURI, $foo );
    ok($tattr);
    ok($tattr->name, $foo);
    ok($tattr->nodeName, $prefix .":".$foo);
    ok($tattr->value, $attvalue2 );

    $elem->removeAttributeNode( $tattr );
    ok( !$elem->hasAttributeNS($nsURI, $foo) );
    # warn $elem->toString() , "\n";
}

print "# 3. Namespace switching\n";
{
    my $elem = XML::LibXML::Element->new($foo);
    ok($elem);

    my $doc = XML::LibXML::Document->new();
    my $e2 = $doc->createElement($foo);
    $doc->setDocumentElement($e2);
    my $nsAttr = $doc->createAttributeNS( $nsURI, $prefix . ":". $foo, $bar);
    ok( $nsAttr );

    $elem->setAttributeNodeNS($nsAttr);
    ok( $elem->hasAttributeNS($nsURI, $foo) );    

    ok( not defined $nsAttr->ownerDocument);
    # warn $elem->toString() , "\n";
} 

print "# 4. Text Append and Normalization\n";

{
    my $doc = XML::LibXML::Document->new();
    my $t1 = $doc->createTextNode( "bar1" );
    my $t2 = $doc->createTextNode( "bar2" );
    my $t3 = $doc->createTextNode( "bar3" );
    my $e  = $doc->createElement("foo");
    $e->appendChild( $t1 );
    $e->appendChild( $t2 );
    $e->appendChild( $t3 );

    my @cn = $e->childNodes;

    # this is the correct behaviour for DOM. the nodes are still
    # refered
    ok( scalar( @cn ), 3 );
    
    $e->normalize;
    
    @cn = $e->childNodes;
    ok( scalar( @cn ), 1 );

    ok(not defined $t2->parentNode);
    ok(not defined $t3->parentNode);
}


print "# 5. XML::LibXML extensions\n";
{
    my $plainstring = "foo";
    my $stdentstring= "$foo & this";
    
    my $doc = XML::LibXML::Document->new();
    my $elem = $doc->createElement( $foo );
    $doc->setDocumentElement( $elem );
    
    $elem->appendText( $plainstring );
    ok( $elem->string_value , $plainstring );

    $elem->appendText( $stdentstring );
    ok( $elem->string_value , $plainstring.$stdentstring );

    $elem->appendTextChild( "foo");
    $elem->appendTextChild( "foo" => "foo&bar" );

    my @cn = $elem->childNodes;
    ok( @cn );
    ok( scalar(@cn), 3 );
    ok( !$cn[1]->hasChildNodes);
    ok( $cn[2]->hasChildNodes);
}
