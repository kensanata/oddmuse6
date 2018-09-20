use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Routes;

my Cro::Service $http = Cro::HTTP::Server.new(
    http => <1.1>,
    host => %*ENV<ODDMUSE_HOST> ||
        die("Missing ODDMUSE_HOST in environment"),
    port => %*ENV<ODDMUSE_PORT> ||
        die("Missing ODDMUSE_PORT in environment"),
    application => routes(),
    after => [
        Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
    ]
);
$http.start;
say "Listening at http://%*ENV<ODDMUSE_HOST>:%*ENV<ODDMUSE_PORT>";
react {
    whenever signal(SIGINT) {
        say "Shutting down...";
        $http.stop;
        done;
    }
}
