type metadata = {
  name : string;
  description : string;
  logo : string option;
  url : string;
  locations : string list;
  consortium : bool;
  featured : bool;
}
[@@deriving of_yaml]

type t = {
  name : string;
  slug : string;
  description : string;
  logo : string option;
  url : string;
  locations : string list;
  consortium : bool;
  featured : bool;
  body_md : string;
  body_html : string;
}
[@@deriving
  stable_record ~version:metadata ~remove:[ slug; body_md; body_html ]]

let of_metadata m = of_metadata m ~slug:(Utils.slugify m.name)

let decode (_, (head, body_md)) =
  let metadata = metadata_of_yaml head in
  let body_html = Omd.of_string body_md |> Omd.to_html in
  Result.map (of_metadata ~body_md ~body_html) metadata

let all () = Utils.map_files decode "industrial_users"

let pp ppf v =
  Fmt.pf ppf
    {|
  { name = %a
  ; slug = %a
  ; description = %a
  ; logo = %a
  ; url = %a
  ; locations = %a
  ; consortium = %a
  ; featured = %a
  ; body_md = %a
  ; body_html = %a
  }|}
    Pp.string v.name Pp.string v.slug Pp.string v.description
    (Pp.option Pp.string) v.logo Pp.string v.url (Pp.list Pp.string) v.locations
    Pp.bool v.consortium Pp.bool v.featured Pp.string v.body_md Pp.string
    v.body_html

let pp_list = Pp.list pp

let template () =
  Format.asprintf
    {|
type t =
  { name : string
  ; slug : string
  ; description : string
  ; logo : string option
  ; url : string
  ; locations : string list
  ; consortium : bool
  ; featured : bool
  ; body_md : string
  ; body_html : string
  }
  
let all = %a
|}
    pp_list (all ())
