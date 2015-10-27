#include "Data.h"

Data::Data( QObject *parent ) :
    QObject(parent)
{
}


/***************************************/
/*************** Getters ***************/
/***************************************/
QString Data::GetOutputDir() const
{
    return m_outputDir;
}

QStringList Data::GetPrefixList() const
{
    return m_PrefixList;
}

QString Data::GetAxialDiffusivityPrefix() const
{
    return m_axialDiffusivityPrefix;
}

QString Data::GetRadialDiffusivityPrefix() const
{
    return m_radialDiffusivityPrefix;
}

QString Data::GetMeanDiffusivityPrefix() const
{
    return m_meanDiffusivityPrefix;
}

QString Data::GetFractionalAnisotropyPrefix() const
{
    return m_fractionalAnisotropyPrefix;
}

QString Data::GetCovariatePrefix() const
{
    return m_covariatesPrefix;
}


QMap<QString, QString> Data::GetFilenameMap() const
{
    return m_filenameMap;
}

QMap< QString, QList<QStringList> > Data::GetDataInFileMap() const
{
    return m_dataInFileMap;
}

QMap<QString, QStringList> Data::GetSubjectsMap() const
{
    return m_SubjectsMap;
}

QMap<QString, int> Data::GetNbrRowsMap() const
{
    return m_nbrRowsMap;
}

QMap<QString, int> Data::GetNbrColumnsMap() const
{
    return m_nbrColumnsMap;
}

QMap<QString, int> Data::GetNbrSubjectsMap() const
{
    return m_nbrSubjectsMap;
}

QString Data::GetFilename( QString pref ) const
{
    return m_filenameMap[ pref ];
}

QList<QStringList> Data::GetDataInFile( QString pref ) const
{
    return m_dataInFileMap[ pref ];
}

QStringList Data::GetSubjects( QString pref ) const
{
    return m_SubjectsMap[ pref ];
}

int Data::GetNbrRows( QString pref ) const
{
    return m_nbrRowsMap[ pref ];
}

int Data::GetNbrColumns( QString pref ) const
{
    return m_nbrColumnsMap[ pref ];
}

int Data::GetNbrSubjects( QString pref ) const
{
    return m_nbrSubjectsMap[ pref ];
}

QMap<int, QString> Data::GetCovariatesList() const
{
    return m_covariatesList;
}


int Data::GetSubjectColumnID() const
{
    return m_subjectColumnID;
}

QMap<QString, QString >::ConstIterator Data::GetFilenameMapIterator()
{
    return m_filenameMap.begin();
}


/***************************************/
/*************** Setters ***************/
/***************************************/
QString& Data::SetOutputDir()
{
    return m_outputDir;
}

QString& Data::SetFilename( QString pref )
 {
     return m_filenameMap[ pref ];
 }

QList<QStringList>& Data::SetDataInFile( QString pref )
 {
     return m_dataInFileMap[ pref ];
 }

QStringList& Data::SetSubjects( QString pref )
{
    return m_SubjectsMap[ pref ];
}

int& Data::SetNbrRows( QString pref )
{
    return m_nbrRowsMap[ pref ];
}

int& Data::SetNbrColumns( QString pref )
{
    return m_nbrColumnsMap[ pref ];
}

int& Data::SetNbrSubjects( QString pref )
{
    return m_nbrSubjectsMap[ pref ];
}

QMap<int, QString>& Data::SetCovariatesList()
{
    return m_covariatesList;
}


QString& Data::SetCovariatesPrefix()
{
    return m_covariatesPrefix;
}

void Data::SetSubjectColumnID( int id )
{
    m_subjectColumnID = id;
}


/***************************************/
/************** Functions **************/
/***************************************/
int Data::InitData()
{
    m_axialDiffusivityPrefix = "ad";
    m_radialDiffusivityPrefix = "rd";
    m_meanDiffusivityPrefix = "md";
    m_fractionalAnisotropyPrefix = "fa";
    m_covariatesPrefix = "COMP";

    m_PrefixList << m_axialDiffusivityPrefix << m_radialDiffusivityPrefix << m_meanDiffusivityPrefix
                 << m_fractionalAnisotropyPrefix << m_covariatesPrefix;

    foreach( QString pref, m_PrefixList )
    {
        m_filenameMap[ pref ];
        m_nbrRowsMap[ pref ];
        m_nbrColumnsMap[ pref ];
        m_nbrSubjectsMap[ pref ];
        ( m_SubjectsMap[ pref ] );
    }

    m_subjectColumnID = 0;

    return m_PrefixList.removeDuplicates();
}

void Data::AddSubject( QString prefID, QString subjectID )
{
    m_SubjectsMap[ prefID ].append( tr( qPrintable( subjectID ) ) );
}

void Data::AddCovariate( int colunmID, QString covariate )
{
    m_covariatesList.insert( colunmID, covariate );
}

void Data::AddIntercept()
{
    m_covariatesList.insert( -1, tr( "Intercept" ) );
    /** The key is -1 so the Intercept is not taken into account as an input covariate **/
}

void Data::ClearFileInformation( QString prefID )
{
    m_filenameMap[ prefID ].clear();
    m_dataInFileMap[ prefID ].clear();
    m_nbrRowsMap[ prefID ] = 0;
    m_nbrColumnsMap[ prefID ] = 0;
    m_nbrSubjectsMap[ prefID ] = 0;
    ( m_SubjectsMap[ prefID ] ).clear();

    if( prefID == m_covariatesPrefix )
    {
        m_covariatesList.clear();
    }
}

void Data::ClearSubjects( QString prefID )
{
    ( m_SubjectsMap[ prefID ] ).clear();
}

void Data::ClearCovariatesList()
{
    m_covariatesList.clear();
}
