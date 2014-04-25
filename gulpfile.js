var gutil = require('gulp-util'),
    fs = require('fs'),
    exec = require('child_process').exec,
    argv = require('yargs').argv,
    gulp = require('gulp'),
    plumber = require('gulp-plumber'),
    livereload = require('gulp-livereload'),
    recess = require('gulp-recess'),
    jshint = require('gulp-jshint'),
    project = argv.p || argv.project;

// =============================================================================
// BEGIN TASKS HERE!

// watch

gulp.task('watch', projectTask(function () {
  gulp.start('serve');
  gulp.start('livereload');
  gulp.start('lint');
}));

// serve

gulp.task('serve', projectTask(function () {
  gutil.log('Booting up the server for ' + gutil.colors.magenta(project));

  exec('rake serve[' + project + ']', function (err, stdout, stderr) {
    gutil.log(gutil.colors.yellow('[jekyll]') + ' ' + stdout);
  });

  gutil.log('Server listening at ' + gutil.colors.magenta('http://0.0.0.0:9292') + '. Press Ctrl + C to stop listening.');
}));

// livereload

gulp.task('livereload', projectTask(function () {
  var server = livereload();
  gulp.watch('src/' + project + '/**').on('change', function (file) {
    server.changed(file.path);
  });
}));

// lint

gulp.task('lint', projectTask(function () {
  gulp.start('lint-css');
  gulp.start('lint-js');
}));

// lint-css

gulp.task('lint-css', projectTask(function () {
  var recessOpts = {
    noOverqualifying: false
  };

  gulp.watch('src/' + project + '/**/*.css').on('change', function (file) {
    gulp.src(file.path)
      .pipe(plumber())
      .pipe(recess(recessOpts));
  });
}));

// lint-js

gulp.task('lint-js', projectTask(function () {
  var jshintOpts = {
    "expr": false
  };

  gulp.watch('src/' + project + '/**/*.js').on('change', function (file) {
    gulp.src(file.path)
      .pipe(plumber())
      .pipe(jshint())
      .pipe(jshint.reporter('default'));
  });
}));

// =============================================================================
// HELP TASK
// ---------
// Place documentation here!

gulp.task('help', function () {
  var title = "Available tasks:",
      exportTitle = "Exporting a project:"
      tasks = [
        {
          title: 'gulp watch -p PROJECT_DIR',
          description: "Runs the serve, livereload and lint tasks simultaneously."
        },
        {
          title: 'gulp serve -p PROJECT_DIR',
          description: "Boots up the server for a project directory."
        },
        {
          title: 'gulp livereload -p PROJECT_DIR',
          description: "Starts a livereload server and refreshes the browser if any files in the project directory were modified."
        },
        {
          title: 'gulp lint -p PROJECT_DIR',
          description: "Runs the lint-css and lint-js tasks simultaneously."
        },
        {
          title: 'gulp lint-css -p PROJECT_DIR',
          description: "Lints CSS files in a project directory after save with RECESS."
        },
        {
          title: 'gulp lint-js -p PROJECT_DIR',
          description: "Lints JS files in a project directory after save with JSHint."
        }
      ];

  // Display the title
  console.log("");
  console.log("    " + gutil.colors.yellow(title));
  console.log("    " + gutil.colors.yellow( Array(title.length + 1).join('=') ));
  console.log("");

  // Show info for each task
  tasks.forEach(function (task) {
    console.log("    " + gutil.colors.blue(task.title));

    // If a line extends past 72 characters (80 - 8 for indentation), then wrap
    // it into a newline. Indent each newline by 8 spaces (2*4 spaces).
    task.description.replace(/(.{72})/g, '$1\n').split('\n').forEach(function (line) {
      console.log("        " + line.replace(/^\s+/,''));
    });

    console.log("");
  });

  // Show info about exporting.
  console.log("    " + gutil.colors.yellow(exportTitle));
  console.log("    " + gutil.colors.yellow( Array(exportTitle.length + 1).join('=') ));
  console.log("");
  console.log("    If you are looking to export a project, please run the command below in " + gutil.colors.magenta('rake') + ":");
  console.log("");
  console.log("        " + gutil.colors.blue("rake export[PROJECT_DIR]"));
  console.log("");
  console.log("    Please run `rake -D export` for more information.");
  console.log("");
});

// =============================================================================
// HELPER FUNCTIONS

// projectTask
// -----------
// Wraps a gulp task callback in a function that checks to see if a valid
// project was passed as an argument. If a valid project was passed, then run
// the task. If not, display an error.

function projectTask (fn) {
  return function () {
    if (!project) {
      gutil.log(gutil.colors.red("Error: Please specify a project directory with the -p flag. Run `gulp help` for more info."));
    } else {
      if (!fs.existsSync('src/' + project)) {
        gutil.log(gutil.colors.red("Error: The project `" + project + "` does not exist. Please verify that this project exists before trying again."));
      } else {
        // Run the task as intended!
        fn.apply(this, arguments);
      }
    }
  }
}
