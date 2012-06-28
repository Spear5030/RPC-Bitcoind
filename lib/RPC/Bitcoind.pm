package RPC::Bitcoind;

use JSON::RPC::Client;

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
	my $port = $opt{'port'} || '8332';
	my $host = $opt{'host'} || 'localhost';
	my $rpc = new JSON::RPC::Client;
	$rpc->ua->credentials(	"$host:$port", 'jsonrpc', $user => $password);
	$self->uri("http://$host:$port/");
	$self->rpc(bless $rpc, JSON::RPC::Client);
	return $self;
};


sub raw{
    my ($self, $obj) = @_;
    my $res=$self->rpc->call($self->uri, $obj);
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
    return $self->raw({method  => 'getbalance', params  => $param});
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
    return $self->raw({method  => 'getblockhash', params  => $param});
}

sub getblock {
    my ($self, $param) = @_;
    return $self->raw({method  => 'getblock', params  => $param});
}

sub getmininginfo {
    my $self= shift;
    return $self->raw({method  => 'getmininginfo'});
}

sub getnewaddress {
    my ($self, $param) = @_;
    return $self->raw({method  => 'getnewaddress', params  => $param});
}

42;