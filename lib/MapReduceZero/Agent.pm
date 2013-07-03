package MapReduceZero::Agent;
use Moo::Role;
use Sys::Hostname qw(hostname);
use Try::Tiny;
use MapReduceZero;

requires 'run';

has id => (
    is => 'lazy',
);

has parent_pid => (
    is      => 'rw',
    default => 0,
);

has child_pid => (
    is      => 'rw',
    default => 0,
);

sub _build_id {
    my ($self) = @_;
    
    return join q{.}, hostname(), $self->child_pid;
}

sub start {
    my ($self) = @_;
    
    die 'Already running'
        if $self->child_pid && kill 0 => $self->child_pid;
    
    $self->parent_pid($$);
    
    my $pid = fork;

    if ($pid > 0) {    
        # Parent
        $self->child_pid($pid);
        return;
    }
    
    # Child
    try {
        my $run = 1;
        
        local $SIG{TERM} = sub { $run = 0 };
        
        while ($run) {
            $self->run();
        }
    }
    catch {
        debug "Unhandled exception '$_'; exiting.";
    };
    
    exit 0;
}

sub stop {
    my ($self) = @_;
    
    if (!$self->parent_pid || $$ ne $self->parent_pid) {
        debug "Tried to stop agent that either hasn't been started or isn't the parent process.";
        return;
    }
    
    kill 'TERM' => $self->child_pid;
}

sub DEMOLISH {
    my ($self) = @_;
    
    return if $$ ne $self->parent_pid;
    
    debug 'Sending TERM to child %s.', $self->child_pid;

    kill 'TERM' => $self->child_pid;

    local $SIG{ALRM} = sub {
        debug 'Sending KILL to unresponsive child %s.', $self->child_pid;
        
        kill 'KILL' => $self->child_pid;
    };
    
    alarm 3;
    
    waitpid $self->child_pid, 0;
    
    alarm 0;
    
    debug 'Child %s exited.', $self->child_pid
        if !kill( 0 => $self->child_pid );
}

1;

