let font_filename = "Timea.ttf"

...
let font = Sdlttf.open_font font_filename 14 in
let text = Sdlttf.render_test_blended font (print_time st) ~fg:Sdlvideo.white in
let position_of_text = Sdlvideo.rect 300 0 300 300 in
...
Sdlvideo.blit_surface ~dst_rect:position_of_text ~src:text ~dst:screen()