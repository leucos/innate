require 'spec/helper'

class One
  include Innate::Node
  map '/'
end

class Two
  include Innate::Node
  map '/two'
end

describe Innate::Helper::Link do
  describe '#route' do
    should 'respond with URI for node' do
      One.route.should == URI('/')
      Two.route.should == URI('/two/')
    end

    should 'respond with URI for node with path /' do
      One.route('/').should == URI('/')
      Two.route('/').should == URI('/two/')
    end

    should 'respond with URI for node with path /foo' do
      One.route('/foo').should == URI('/foo')
      One.route(:foo).should == URI('/foo')

      Two.route('/foo').should == URI('/two/foo')
      Two.route(:foo).should == URI('/two/foo')
    end

    should 'respond with URI for node with path /foo/bar' do
      One.route('/foo/bar').should == URI('/foo/bar')
      One.route(:foo, :bar).should == URI('/foo/bar')

      Two.route('/foo/bar').should == URI('/two/foo/bar')
      Two.route(:foo, :bar).should == URI('/two/foo/bar')
    end

    should 'respond with URI for node with GET params' do
      One.route('/', :a => :b).should == URI('/?a=b')

      One.route('/foo', :a => :b).should == URI('/foo?a=b')
      One.route(:foo, :a => :b  ).should == URI('/foo?a=b')

      One.route('/foo/bar', :a => :b).should == URI('/foo/bar?a=b')
      One.route(:foo, :bar, :a => :b).should == URI('/foo/bar?a=b')

      Two.route('/', :a => :b).should == URI('/two/?a=b')

      Two.route('foo', :a => :b).should == URI('/two/foo?a=b')
      Two.route(:foo, :a => :b ).should == URI('/two/foo?a=b')
      Two.route('/foo/bar', :a => :b).should == URI('/two/foo/bar?a=b')
      Two.route(:foo, :bar, :a => :b).should == URI('/two/foo/bar?a=b')
    end

    should 'prefix the links as defined in the options' do
      Innate::Node.options.prefix = '/bar'
      One.route('/foo').should == URI('/bar/foo')
      Innate::Node.options.prefix = '/'
    end
  end

  describe '#anchor' do
    should 'respond with a tag with default text' do
      One.anchor('hello').should == '<a href="/hello">hello</a>'
      Two.anchor('hello').should == '<a href="/two/hello">hello</a>'
    end

    should 'respond with a tag with explicit text' do
      One.anchor('hello', :foo).should == '<a href="/foo">hello</a>'
      Two.anchor('hello', :foo).should == '<a href="/two/foo">hello</a>'
    end

    should 'pass parameters to #route' do
      One.anchor('hello', :foo, :a => :b).
        should == '<a href="/foo?a=b">hello</a>'
      Two.anchor('hello', :foo, :a => :b).
        should == '<a href="/two/foo?a=b">hello</a>'
    end

    should 'escape text' do
      One.anchor('<blink> & <a>', :foo).
        should == '<a href="/foo">&lt;blink&gt; &amp; &lt;a&gt;</a>'
    end
  end

  describe 'combining #anchor and #route' do
    should 'not escape twice' do
      One.anchor('foo', One.route(:index, :bar => 'a/b/c')).
        should == '<a href="/index?bar=a%2Fb%2Fc">foo</a>'
    end

    should 'handle complete uris gracefully' do
      One.anchor('foo', 'http://example.com/?foo=bar&baz=qux').
        should == '<a href="http://example.com/?foo=bar&amp;baz=qux">foo</a>'
    end
  end
end
