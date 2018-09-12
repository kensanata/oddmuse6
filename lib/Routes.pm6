use Cro::HTTP::Router;
use Pages;

sub routes() is export {
    route {
        get -> 'edit', $id {
            content 'text/html', "<h1>Editing {$id}</h1>";
        }
        get -> $id {
            content 'text/html', get-html-page($id);
        }
        get -> {
            content 'text/html', get-html-page("Home");
        }
    }
}
