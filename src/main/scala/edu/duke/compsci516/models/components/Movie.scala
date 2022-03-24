package edu.duke.compsci516.models.components

import slick.jdbc.JdbcBackend.Database
import slick.jdbc.JdbcProfile

import scala.concurrent.Future

import _root_.edu.duke.compsci516.models.entity._
import _root_.edu.duke.compsci516.models.database._
import scala.util.Success
import scala.concurrent.ExecutionContext

trait MovieRepositoryComponent {
  def add(movie: MovieDetailRow): Future[MovieDetailRow]

  def get(
      movieId: Int
  ): Future[Option[MovieDetailRow]]

  def getGenres(movieId: Int): Future[Seq[Genre]]

  def getCrews(movieId: Int): Future[Seq[MovieCrew]]

  def getMoviesByGenre(
      genreId: Int,
      sortKey: String,
      limit: Int,
      offset: Int
  ): Future[PaginatedResult[MovieDetailRow]]
}

class MovieRepository(db: Database) extends MovieRepositoryComponent {
  protected val movieDetailTable = MovieDetailTable
  protected val genreTable = GenreTable
  protected val movieGenreTable = MovieGenreTable
  protected val movieCrewTable = MovieCrewTable
  protected val crewTable = CrewTable
  implicit val ec: ExecutionContext = scala.concurrent.ExecutionContext.global

  import movieDetailTable.profile.api._
  import movieDetailTable.MovieDetailRows
  import genreTable.GenreRows
  import movieGenreTable.MovieGenreRows
  import movieCrewTable.MovieCrewRows
  import crewTable.CrewRows

  override def add(movie: MovieDetailRow): Future[MovieDetailRow] = db.run {
    (MovieDetailRows returning MovieDetailRows) += movie
  }

  override def get(
      movieId: Int
  ): Future[Option[MovieDetailRow]] = db.run {
    MovieDetailRows.filter(_.id === movieId).result.headOption
  }

  override def getGenres(movieId: Int): Future[Seq[Genre]] = db.run {
    MovieGenreRows
      .filter(_.movieId === movieId)
      .join(GenreRows)
      .on(_.genreId === _.id)
      .map { _._2 }
      .result
  }

  override def getCrews(movieId: Int): Future[Seq[MovieCrew]] =
    db.run {
      MovieCrewRows
        .filter(_.movieId === movieId)
        .result
    }

  override def getMoviesByGenre(
      genreId: Int,
      sortKey: String,
      limit: Int,
      offset: Int
  ): Future[PaginatedResult[MovieDetailRow]] = db.run {

    val q = MovieGenreRows
      .filter(_.genreId === genreId)
      .join(MovieDetailRows)
      .on(_.movieId === _.id)
      .map(_._2)

    val q_sort = sortKey match {
      case "popularity.desc"   => q.sortBy(_.popularity.desc)
      case "vote_average.desc" => q.sortBy(_.voteAverage.desc)
      case "vote_count.desc"   => q.sortBy(_.voteCount.desc)
      case "title.desc"        => q.sortBy(_.title.desc)
      case "release_date.desc" => q.sortBy(_.releaseDate.desc)
      case _                   => q
    }
    for {
      numberOfRows <- q_sort.length.result
      res <- q_sort.drop(offset).take(limit).result
    } yield PaginatedResult(
      totalCount = numberOfRows,
      entities = res.toList,
      hasNextPage = numberOfRows - (offset + limit) > 0
    )
  }

}
