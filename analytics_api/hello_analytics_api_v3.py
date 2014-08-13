#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys,codecs,csv
import hello_analytics_api_v3_auth   # import the Auth Helper class

from apiclient.errors import HttpError
from oauth2client.client import AccessTokenRefreshError

# Fix for various character encoding errors for output
if sys.stdout.encoding != 'UTF-8':
  sys.stdout = codecs.getwriter('UTF-8')(sys.stdout, 'strict')

def main(argv):
  # Initialize the Analytics Service Object
  service = hello_analytics_api_v3_auth.initialize_service()

  try:
    # Query APIs, print results
    profile_id = get_profile_id(service)

    if profile_id:
      results = get_results(service, profile_id)
      print_results(results)

  except TypeError, error:
    # Handle errors in constructing a query.
    print ('There was an error in constructing your query : %s' % error)

  except HttpError, error:
    # Handle API errors.
    print ('Arg, there was an API error : %s : %s' %
           (error.resp.status, error._get_reason()))

  except AccessTokenRefreshError:
    # Handle Auth errors.
    print ('The credentials have been revoked or expired, please re-run '
           'the application to re-authorize')


def get_profile_id(service):
  # Get a list of all Google Analytics accounts for this user
  accounts = service.management().accounts().list().execute()

  if accounts.get('items'):
    # Get the first Google Analytics account
    firstAccountId = accounts.get('items')[1].get('id')

    # Get a list of all the Web Properties for the first account
    webproperties = service.management().webproperties().list(accountId=firstAccountId).execute()

    if webproperties.get('items'):
      # Get the first Web Property ID
      firstWebpropertyId = webproperties.get('items')[0].get('id')

      # Get a list of all Views (Profiles) for the first Web Property of the first Account
      profiles = service.management().profiles().list(
          accountId=firstAccountId,
          webPropertyId=firstWebpropertyId).execute()

      if profiles.get('items'):
        # return the first View (Profile) ID
        return profiles.get('items')[0].get('id')

  return None


def get_results(service, profile_id):
  # Use the Analytics Service Object to query the Core Reporting API
  return service.data().ga().get(
      ids='ga:' + profile_id,
      start_date='2014-02-03',
      end_date='2014-03-03',
      metrics='ga:sessions',
	  dimensions='ga:country').execute()


def print_results(results):
  # Print data nicely for the user.
  if results:
	print_report_info(results)
	print_pagination_info(results)
	print_profile_info(results)
	print_query(results)
	print_column_headers(results)
	print_totals_for_all_results(results)
	print_rows(results)

  else:
    print 'No results found'


def print_report_info(results):
  """Prints general information about this report.

  Args:
    results: The response returned from the Core Reporting API.
  """

  print 'Report Infos:'
  print 'Contains Sampled Data = %s' % results.get('containsSampledData')
  print 'Kind                  = %s' % results.get('kind')
  print 'ID                    = %s' % results.get('id')
  print 'Self Link             = %s' % results.get('selfLink')
  print


def print_pagination_info(results):
  """Prints common pagination details.

  Args:
    results: The response returned from the Core Reporting API.
  """

  print 'Pagination Infos:'
  print 'Items per page = %s' % results.get('itemsPerPage')
  print 'Total Results  = %s' % results.get('totalResults')

  # These only have values if other result pages exist.
  if results.get('previousLink'):
    print 'Previous Link  = %s' % results.get('previousLink')
  if results.get('nextLink'):
    print 'Next Link      = %s' % results.get('nextLink')
  print


def print_profile_info(results):
  """Prints information about the profile.

  Args:
    results: The response returned from the Core Reporting API.
  """

  print 'Profile Infos:'
  info = results.get('profileInfo')
  print 'Account Id      = %s' % info.get('accountId')
  print 'Web Property Id = %s' % info.get('webPropertyId')
  print 'Profile Id      = %s' % info.get('profileId')
  print 'Table Id        = %s' % info.get('tableId')
  print 'Profile Name    = %s' % info.get('profileName')
  print


def print_query(results):
  """The query returns the original report query as a dict.

  Args:
    results: The response returned from the Core Reporting API.
  """

  print 'Query Parameters:'
  query = results.get('query')
  for key, value in query.iteritems():
    print '%s = %s' % (key, value)
  print


def print_column_headers(results):
  """Prints the information for each column.

  The main data from the API is returned as rows of data. The column
  headers describe the names and types of each column in rows.


  Args:
    results: The response returned from the Core Reporting API.
  """

  print 'Column Headers:'
  headers = results.get('columnHeaders')
  for header in headers:
    # Print Dimension or Metric name.
    print '\t%s name:    = %s' % (header.get('columnType').title(),
                                  header.get('name'))
    print '\tColumn Type = %s' % header.get('columnType')
    print '\tData Type   = %s' % header.get('dataType')
    print


def print_totals_for_all_results(results):
  """Prints the total metric value for all pages the query matched.

  Args:
    results: The response returned from the Core Reporting API.
  """

  print 'Total Metrics For All Results:'
  print 'This query returned %s rows.' % len(results.get('rows'))
  print ('But the query matched %s total results.' %
         results.get('totalResults'))
  print 'Here are the metric totals for the matched total results.'
  totals = results.get('totalsForAllResults')

  for metric_name, metric_total in totals.iteritems():
    print 'Metric Name  = %s' % metric_name
    print 'Metric Total = %s' % metric_total
    print


def print_rows(results):
  """Prints all the rows of data returned by the API.

  Args:
    results: The response returned from the Core Reporting API.
  """
  # Opens and writes rows into CSV file
  #writer = csv.writer(codecs.open('test.csv','w', encoding='UTF-8', errors='replace'))
  print 'Rows:'
  if results.get('rows', []):
    for row in results.get('rows'):
      #row_encode = row.encode('utf-8')
      print '\t'.join(row)
      #writer.writerow(row)
  else:
    print 'No Rows Found'
  
  #close('test.csv')

if __name__ == '__main__':
  main(sys.argv)
