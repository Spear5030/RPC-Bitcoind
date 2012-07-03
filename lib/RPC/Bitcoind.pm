package RPC::Bitcoind;

use JSON::RPC::Client;
use Data::Dumper;
use Carp;

BEGIN {
    for my $method (qw/uri rpc status error is_error/) {
        eval qq|
            sub $method {
                \$_[0]->{$method} = \$_[1] if defined \$_[1];
                \$_[0]->{$method};
            }
        |;
    }
}


sub new {
	my $proto = shift;
	my %opt = @_;
	my $self  = bless {}, (ref $proto ? ref $proto : $proto);
	my $user = $opt{'user'} || '';
	my $password = $opt{'password'};
	croak "Need password." unless $password;
	my $port = $opt{'port'} || '8332';
	my $host = $opt{'host'} || 'localhost';
	my $rpc = new JSON::RPC::Client;
	$rpc->ua->credentials(	"$host:$port", 'jsonrpc', $user => $password);
	$rpc->ua->timeout(20);
	$self->uri("http://$host:$port/");
	$self->rpc(bless $rpc, JSON::RPC::Client);
	return $self;
};


sub raw{
    my $self = shift;
    my $res=$self->rpc->call($self->uri, @_);
    if ($res){
      if ($res->is_error) {
         $self->is_error(1); 
         $self->error($res->error_message);
         return; }
      else { 
          return $res->result;
          }
    };
};

sub getstatus {
    my $self= shift;
    return $self->rpc->status_line;
};

sub getbalance {
    my ($self, $param) = @_;
    return $self->raw({method  => 'getbalance', param  => $param});
}

sub getdifficulty {
    my $self= shift;
    return $self->raw({method  => 'getdifficulty'});
}

sub getinfo {
    my $self= shift;
    return $self->raw({method  => 'getinfo'});
}
sub getblockcount {
    my $self= shift;
    return $self->raw({method  => 'getblockcount'});
}

sub getblockhash {
    my ($self, $param) = @_;
    return $self->raw({method  => 'getblockhash', param  => $param});
}

sub getblock {
    my ($self, $param) = @_;
    return $self->raw({method  => 'getblock', param  => $param});
}

sub getmininginfo {
    my $self= shift;
    return $self->raw({method  => 'getmininginfo'});
}

sub getnewaddress {
    my ($self, $param) = @_;
    return $self->raw({method  => 'getnewaddress', param  => $param});
}

sub listaccounts {
    my $self = shift;
    return $self->raw({method  => 'listaccounts'});
}

sub getaddressesbyaccount{
    my ($self, $param) = @_; 
    return ($self->raw({method  => 'getaddressesbyaccount', params  => [$param]}));
}


sub validateaddress {
    my ($self, $param) = @_; 
    my %res = %{$self->raw({method  => 'validateaddress', params  => [$param]})};
    return $res{isvalid};
}


sub setaccount {
    my ($self, $address, $account) = @_; 
    my $res = $self->raw({method  => 'setaccount', params  => [$address, $account]});
    return $res;
}


42;