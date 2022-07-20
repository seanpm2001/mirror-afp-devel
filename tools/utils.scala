/* Author: Fabian Huch, TU Muenchen

Utilities.
 */
package afp


import isabelle._

import scala.collection.immutable.ListMap

import java.net.URL
import java.io.{BufferedReader, InputStreamReader, IOException}


object Utils {
  val TIMEOUT = 30*1000

  def group_sorted[A, K](l: List[A], f: A => K): ListMap[K, List[A]] =
    l.foldLeft(ListMap.empty[K, List[A]]) {
      case (m, a) =>
        m.updatedWith(f(a)) {
          case Some(as) => Some(as :+ a)
          case None => Some(List(a))
        }
    }

  def grouped_sorted[A, K](l: List[A], f: A => K): ListMap[K, A] =
    group_sorted(l, f).map {
      case (k, v :: Nil) => k -> v
      case (k, vs) => error("Not distinct for " + quote(k.toString) + ": " + commas_quote(vs.map(_.toString)))
    }

  def the_entry[K, V](m: Map[K, V], k: K): V = m.getOrElse(k, error("Expected key " + quote(k.toString)))

  def fetch_text(url: URL, params: Map[String, String]): String =
    try {
      val conn = url.openConnection()
      conn.setConnectTimeout(TIMEOUT)
      conn.setReadTimeout(TIMEOUT)
      params.foreach { case (param, value) => conn.setRequestProperty(param, value) }
      File.read_stream(conn.getInputStream)
    } catch {
      case _: IOException => error("Could not read from " + quote(url.toString))
    }
}