

has.col = function(x, col) {
  col %in% names(x)
}

art_to_ejd_art = function(art, db, pdf.file = NULL) {
  if (!has.col(art,"authors")) {
    authors = dbGet(db, "author",list(id=art$id))

    art$authors =enc2utf8(paste0(authors$author, collapse=", "))
  }

  art$pdf.file = pdf.file
  art$has.pdf = !is.null(pdf.file)
  art

}

update_gha_repbox_art = function(art, repodir,db) {
  restore.point("update_gha_repbox_art")
  if (!isTRUE(art$repo=="oi")) {
    cat("\nWe can currently only use Github Actions for OpenICPSR articles.")
    return()
  }
  ejd_art = art_to_ejd_art(art,db)
  project_dir = paste0(repodir,"/project")
  if (!dir.exists(file.path(project_dir,"meta"))) {
    dir.create(file.path(project_dir,"meta"))
  }
  saveRDS(ejd_art, file.path(project_dir, "meta","ejd_art.Rds"))

  oi_id = str.between(art$data_url,"openicpsr/project/","/")
  yaml::write_yaml(list(repo_type="oi",repo_id = oi_id), file.path(repodir, "repbox_config.yml"))

}

write_ejd_gha_status = function(project_dir, status, runid, log.txt) {
  runid = as.character(runid)

  # Write current state
  gha.dir = file.path(project_dir, "gha")
  if (!dir.exists(gha.dir)) dir.create(gha.dir, recursive = TRUE)
  writeLines(status, file.path(gha.dir,"gha_status.txt"))
  writeLines(runid, file.path(gha.dir,"gha_runid.txt"))
  writeLines(log.txt, file.path(gha.dir,"gha_log.txt"))

  # Write permanent state
  #gha.dir = file.path(project_dir, "gha", format(Sys.time(),"%Y_%m_%d-%H%M"))
  #if (!dir.exists(gha.dir)) dir.create(gha.dir, recursive = TRUE)
  #writeLines(status, file.path(gha.dir,"gha_status.txt"))
  #writeLines(runid, file.path(gha.dir,"gha_runid.txt"))
  #writeLines(log.txt, file.path(gha.dir,"gha_log.txt"))
}
