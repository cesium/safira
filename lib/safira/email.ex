defmodule Safira.Email do
  @moduledoc """
  The emails used by safira
  """
  # use Bamboo.Phoenix, view: Safira.FeedbackView
  import Bamboo.Email


  def send_reset_email(to_email, token) do
    new_email()
    |> to(to_email)
    |> from(System.get_env("FROM_EMAIL"))
    |> subject("Reset Password Instructions")
    |> html_body(build_email_text(token))
    |> Safira.Mailer.deliver_now()
  end

  def send_discord_registration_email(to_email, token, discord_association_code) do
    Mix.shell().info(to_email)

    new_email()
    |> to(to_email)
    |> from(
      {Application.fetch_env!(:safira, :from_email_name),
       Application.fetch_env!(:safira, :from_email)}
    )
    |> subject("[SEI'22] Finalizar Registo e Informações")
    |> html_body(build_discord_email_text(token, discord_association_code))
    |> Safira.Mailer.deliver_now()
  end

  def send_registration_email(to_email, token) do
    Mix.shell().info(to_email)

    new_email()
    |> to(to_email)
    |> from(
      {Application.fetch_env!(:safira, :from_email_name),
       Application.fetch_env!(:safira, :from_email)}
    )
    |> subject("[SEI'22] Finalizar Registo e Informações")
    |> html_body(build_email_text(token))
    |> Safira.Mailer.deliver_now()
  end

  defp build_reset_password_email_text(token) do
    password_reset_link = "#{System.get_env("FRONTEND_URL")}/reset?token=#{token}"

    """
    Please visit <a href="#{password_reset_link}">Reset Your Password</a> to reset your password
    """
  end

  defp build_discord_email_text(token, discord_association_code) do
    password_reset_link = "#{System.get_env("FRONTEND_URL")}/reset?token=#{token}"

    discord_invite_url = Application.fetch_env!(:safira, :discord_invite_url)

    """
    Please visit #{password_reset_link} to finish your account registration.
    Join the Discord: #{discord_invite_url}
    Your Discord Association Code is: #{discord_association_code}
    """
  end

  defp build_reset_password_email_text(token) do
    password_reset_link = "#{System.get_env("FRONTEND_URL")}/reset?token=#{token}"

    """
    Please visit <a href="#{password_reset_link}">Reset Your Password</a> to reset your password
    """
  end

  defp build_email_text(token) do
    password_reset_link = "#{System.get_env("FRONTEND_URL")}/reset?token=#{token}"
    discord_invite_url = Application.fetch_env!(:safira, :discord_invite_url)

    """
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html
      data-editor-version="2"
      class="sg-campaigns"
      xmlns="http://www.w3.org/1999/xhtml"
    >
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta
          name="viewport"
          content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1"
        />
        <!--[if !mso]><!-->
        <meta http-equiv="X-UA-Compatible" content="IE=Edge" />
        <!--<![endif]-->
        <!--[if (gte mso 9)|(IE)]>
          <xml>
            <o:OfficeDocumentSettings>
              <o:AllowPNG />
              <o:PixelsPerInch>96</o:PixelsPerInch>
            </o:OfficeDocumentSettings>
          </xml>
        <![endif]-->
        <!--[if (gte mso 9)|(IE)]>
          <style type="text/css">
            body {
              width: 600px;
              margin: 0 auto;
            }
            table {
              border-collapse: collapse;
            }
            table,
            td {
              mso-table-lspace: 0pt;
              mso-table-rspace: 0pt;
            }
            img {
              -ms-interpolation-mode: bicubic;
            }
          </style>
        <![endif]-->
        <style type="text/css">
          body,
          p,
          div {
            font-family: inherit;
            font-size: 14px;
          }
          body {
            color: #000000;
          }
          body a {
            color: #1188e6;
            text-decoration: none;
          }
          p {
            margin: 0;
            padding: 0;
          }
          table.wrapper {
            width: 100% !important;
            table-layout: fixed;
            -webkit-font-smoothing: antialiased;
            -webkit-text-size-adjust: 100%;
            -moz-text-size-adjust: 100%;
            -ms-text-size-adjust: 100%;
          }
          img.max-width {
            max-width: 100% !important;
          }
          .column.of-2 {
            width: 50%;
          }
          .column.of-3 {
            width: 33.333%;
          }
          .column.of-4 {
            width: 25%;
          }
          ul ul ul ul {
            list-style-type: disc !important;
          }
          ol ol {
            list-style-type: lower-roman !important;
          }
          ol ol ol {
            list-style-type: lower-latin !important;
          }
          ol ol ol ol {
            list-style-type: decimal !important;
          }
          @media screen and (max-width: 480px) {
            .preheader .rightColumnContent,
            .footer .rightColumnContent {
              text-align: left !important;
            }
            .preheader .rightColumnContent div,
            .preheader .rightColumnContent span,
            .footer .rightColumnContent div,
            .footer .rightColumnContent span {
              text-align: left !important;
            }
            .preheader .rightColumnContent,
            .preheader .leftColumnContent {
              font-size: 80% !important;
              padding: 5px 0;
            }
            table.wrapper-mobile {
              width: 100% !important;
              table-layout: fixed;
            }
            img.max-width {
              height: auto !important;
              max-width: 100% !important;
            }
            a.bulletproof-button {
              display: block !important;
              width: auto !important;
              font-size: 80%;
              padding-left: 0 !important;
              padding-right: 0 !important;
            }
            .columns {
              width: 100% !important;
            }
            .column {
              display: block !important;
              width: 100% !important;
              padding-left: 0 !important;
              padding-right: 0 !important;
              margin-left: 0 !important;
              margin-right: 0 !important;
            }
            .social-icon-column {
              display: inline-block !important;
            }
          }
        </style>
        <!--user entered Head Start-->
        <link
          href="https://fonts.googleapis.com/css?family=Chivo&display=swap"
          rel="stylesheet"
        />
        <style>
          body {
            font-family: "Chivo", sans-serif;
          }
        </style>
        <!--End Head user entered-->
      </head>
      <body>
        <center
          class="wrapper"
          data-link-color="#1188E6"
          data-body-style="font-size:14px; font-family:inherit; color:#000000; background-color:#f7f7f7;"
        >
          <div class="webkit">
            <table
              cellpadding="0"
              cellspacing="0"
              border="0"
              width="100%"
              class="wrapper"
              bgcolor="#f7f7f7"
            >
              <tr>
                <td valign="top" bgcolor="#f7f7f7" width="100%">
                  <table
                    width="100%"
                    role="content-container"
                    class="outer"
                    align="center"
                    cellpadding="0"
                    cellspacing="0"
                    border="0"
                  >
                    <tr>
                      <td width="100%">
                        <table
                          width="100%"
                          cellpadding="0"
                          cellspacing="0"
                          border="0"
                        >
                          <tr>
                            <td>
                              <!--[if mso]>
        <center>
        <table><tr><td width="600">
      <![endif]-->
                              <table
                                width="100%"
                                cellpadding="0"
                                cellspacing="0"
                                border="0"
                                style="width: 100%; max-width: 600px"
                                align="center"
                              >
                                <tr>
                                  <td
                                    role="modules-container"
                                    style="
                                      padding: 0px 0px 0px 0px;
                                      color: #000000;
                                      text-align: left;
                                    "
                                    bgcolor="#FFFFFF"
                                    width="100%"
                                    align="left"
                                  >
                                    <table
                                      class="module preheader preheader-hide"
                                      role="module"
                                      data-type="preheader"
                                      border="0"
                                      cellpadding="0"
                                      cellspacing="0"
                                      width="100%"
                                      style="
                                        display: none !important;
                                        mso-hide: all;
                                        visibility: hidden;
                                        opacity: 0;
                                        color: transparent;
                                        height: 0;
                                        width: 0;
                                      "
                                    >
                                      <tr>
                                        <td role="module-content">
                                          <p></p>
                                        </td>
                                      </tr>
                                    </table>
                                    <table
                                      border="0"
                                      cellpadding="0"
                                      cellspacing="0"
                                      align="center"
                                      width="100%"
                                      role="module"
                                      data-type="columns"
                                      style="padding: 50px 30px 0px 30px"
                                      bgcolor="#01253d"
                                      data-distribution="1"
                                    >
                                      <tbody>
                                        <tr role="module-content">
                                          <td height="100%" valign="top">
                                            <table
                                              width="484"
                                              style="
                                                width: 484px;
                                                border-spacing: 0;
                                                border-collapse: collapse;
                                                margin: 0px 26px 0px 26px;
                                              "
                                              cellpadding="0"
                                              cellspacing="0"
                                              align="left"
                                              border="0"
                                              bgcolor=""
                                              class="column column-0"
                                            >
                                              <tbody>
                                                <tr>
                                                  <td
                                                    style="
                                                      padding: 0px;
                                                      margin: 0px;
                                                      border-spacing: 0;
                                                    "
                                                  >
                                                    <table
                                                      class="wrapper"
                                                      role="module"
                                                      data-type="image"
                                                      border="0"
                                                      cellpadding="0"
                                                      cellspacing="0"
                                                      width="100%"
                                                      style="table-layout: fixed"
                                                      data-muid="70bf8541-5d04-42ed-95be-d461ccb09d81"
                                                    >
                                                      <tbody>
                                                        <tr>
                                                          <td
                                                            style="
                                                              font-size: 6px;
                                                              line-height: 10px;
                                                              padding: 0px 0px 0px
                                                                0px;
                                                            "
                                                            valign="top"
                                                            align="center"
                                                          >
                                                            <img
                                                              class="max-width"
                                                              border="0"
                                                              style="
                                                                display: block;
                                                                color: #000000;
                                                                text-decoration: none;
                                                                font-family: Helvetica,
                                                                  arial, sans-serif;
                                                                font-size: 16px;
                                                                max-width: 50% !important;
                                                                width: 50%;
                                                                height: auto !important;
                                                              "
                                                              width="242"
                                                              alt=""
                                                              data-proportionally-constrained="false"
                                                              data-responsive="true"
                                                              src="https://sei22-prod.s3.eu-west-3.amazonaws.com/emails/sei-logo.png"
                                                            />
                                                          </td>
                                                        </tr>
                                                      </tbody>
                                                    </table>
                                                    <table
                                                      class="module"
                                                      role="module"
                                                      data-type="text"
                                                      border="0"
                                                      cellpadding="0"
                                                      cellspacing="0"
                                                      width="100%"
                                                      style="table-layout: fixed"
                                                      data-muid="378a178d-727b-4c10-aca9-5fe2cee40fa3"
                                                      data-mc-module-version="2019-10-22"
                                                    >
                                                      <tbody>
                                                        <tr>
                                                          <td
                                                            style="
                                                              padding: 18px 30px
                                                                10px 30px;
                                                              line-height: 20px;
                                                              text-align: inherit;
                                                            "
                                                            height="100%"
                                                            valign="top"
                                                            bgcolor=""
                                                            role="module-content"
                                                          >
                                                            <div>
                                                              <div
                                                                style="
                                                                  font-family: inherit;
                                                                  text-align: center;
                                                                "
                                                              >
                                                                <span
                                                                  style="
                                                                    font-style: normal;
                                                                    font-variant-ligatures: normal;
                                                                    font-variant-caps: normal;
                                                                    font-weight: 400;
                                                                    letter-spacing: normal;
                                                                    text-align: left;
                                                                    text-indent: 0px;
                                                                    text-transform: none;
                                                                    white-space: normal;
                                                                    word-spacing: 0px;
                                                                    -webkit-text-stroke-width: 0px;
                                                                    text-decoration-thickness: initial;
                                                                    text-decoration-style: initial;
                                                                    text-decoration-color: initial;
                                                                    float: none;
                                                                    display: inline;
                                                                    color: #ffffff;
                                                                    font-family: arial,
                                                                      helvetica,
                                                                      sans-serif;
                                                                    font-size: 18px;
                                                                  "
                                                                  >Olá, caro(a)
                                                                  participante,</span
                                                                ><span
                                                                  style="
                                                                    color: #ffffff;
                                                                    font-family: arial,
                                                                      helvetica,
                                                                      sans-serif;
                                                                    font-size: 18px;
                                                                  "
                                                                  ><br /> </span
                                                                ><span
                                                                  style="
                                                                    font-style: normal;
                                                                    font-variant-ligatures: normal;
                                                                    font-variant-caps: normal;
                                                                    font-weight: 400;
                                                                    letter-spacing: normal;
                                                                    text-align: left;
                                                                    text-indent: 0px;
                                                                    text-transform: none;
                                                                    white-space: normal;
                                                                    word-spacing: 0px;
                                                                    -webkit-text-stroke-width: 0px;
                                                                    text-decoration-thickness: initial;
                                                                    text-decoration-style: initial;
                                                                    text-decoration-color: initial;
                                                                    float: none;
                                                                    display: inline;
                                                                    color: #ffffff;
                                                                    font-family: arial,
                                                                      helvetica,
                                                                      sans-serif;
                                                                    font-size: 18px;
                                                                  "
                                                                  >Está tudo pronto
                                                                  para o início da
                                                                  SEI'22!</span
                                                                >
                                                              </div>
                                                              <div
                                                                style="
                                                                  font-family: inherit;
                                                                  text-align: center;
                                                                "
                                                              >
                                                                <br />
                                                              </div>
                                                              <div
                                                                style="
                                                                  font-family: inherit;
                                                                  text-align: center;
                                                                "
                                                              >
                                                                <span
                                                                  style="
                                                                    font-style: normal;
                                                                    font-variant-ligatures: normal;
                                                                    font-variant-caps: normal;
                                                                    font-weight: 400;
                                                                    letter-spacing: normal;
                                                                    text-align: left;
                                                                    text-indent: 0px;
                                                                    text-transform: none;
                                                                    white-space: normal;
                                                                    word-spacing: 0px;
                                                                    -webkit-text-stroke-width: 0px;
                                                                    text-decoration-thickness: initial;
                                                                    text-decoration-style: initial;
                                                                    text-decoration-color: initial;
                                                                    float: none;
                                                                    display: inline;
                                                                    color: #ffffff;
                                                                    font-family: arial,
                                                                      helvetica,
                                                                      sans-serif;
                                                                    font-size: 18px;
                                                                  "
                                                                  >Como em edições
                                                                  passadas,&nbsp;haverá
                                                                  uma plataforma
                                                                  online onde
                                                                  poderás ver os
                                                                  teus badges e
                                                                  redimir prémios
                                                                  com os tokens que
                                                                  ganhas.</span
                                                                >
                                                              </div>
                                                              <div
                                                                style="
                                                                  font-family: inherit;
                                                                  text-align: center;
                                                                "
                                                              >
                                                                <br />
                                                              </div>
                                                              <div
                                                                style="
                                                                  font-family: inherit;
                                                                  text-align: center;
                                                                "
                                                              >
                                                                <span
                                                                  style="
                                                                    font-style: normal;
                                                                    font-variant-ligatures: normal;
                                                                    font-variant-caps: normal;
                                                                    font-weight: 400;
                                                                    letter-spacing: normal;
                                                                    text-align: left;
                                                                    text-indent: 0px;
                                                                    text-transform: none;
                                                                    white-space: normal;
                                                                    word-spacing: 0px;
                                                                    -webkit-text-stroke-width: 0px;
                                                                    text-decoration-thickness: initial;
                                                                    text-decoration-style: initial;
                                                                    text-decoration-color: initial;
                                                                    float: none;
                                                                    display: inline;
                                                                    color: #ffffff;
                                                                    font-family: arial,
                                                                      helvetica,
                                                                      sans-serif;
                                                                    font-size: 18px;
                                                                  "
                                                                  >Descobre mais
                                                                  sobre...</span
                                                                >
                                                              </div>
                                                              <div></div>
                                                            </div>
                                                          </td>
                                                        </tr>
                                                      </tbody>
                                                    </table>
                                                    <table
                                                      border="0"
                                                      cellpadding="0"
                                                      cellspacing="0"
                                                      class="module"
                                                      data-role="module-button"
                                                      data-type="button"
                                                      role="module"
                                                      style="table-layout: fixed"
                                                      width="100%"
                                                      data-muid="9faecb59-dc1a-4a48-ad3a-7a893b1fc41b.3"
                                                    >
                                                      <tbody>
                                                        <tr>
                                                          <td
                                                            align="center"
                                                            bgcolor=""
                                                            class="outer-td"
                                                            style="
                                                              padding: 0px 0px 5px 0px;
                                                            "
                                                          >
                                                            <table
                                                              border="0"
                                                              cellpadding="0"
                                                              cellspacing="0"
                                                              class="wrapper-mobile"
                                                              style="
                                                                text-align: center;
                                                              "
                                                            >
                                                              <tbody>
                                                                <tr>
                                                                  <td
                                                                    align="center"
                                                                    bgcolor="#01253d"
                                                                    class="inner-td"
                                                                    style="
                                                                      border-radius: 6px;
                                                                      font-size: 16px;
                                                                      text-align: center;
                                                                      background-color: inherit;
                                                                    "
                                                                  >
                                                                    <a
                                                                      href="https://www.instagram.com/p/CZSdDyVAWJm/"
                                                                      style="
                                                                        background-color: #01253d;
                                                                        border: 2px
                                                                          solid
                                                                          #ffffff;
                                                                        border-color: #ffffff;
                                                                        border-radius: 30px;
                                                                        border-width: 2px;
                                                                        display: inline-block;
                                                                        font-size: 16px;
                                                                        font-weight: bold;
                                                                        letter-spacing: 0px;
                                                                        line-height: normal;
                                                                        padding: 12px
                                                                          40px 12px
                                                                          40px;
                                                                        text-align: center;
                                                                        text-decoration: none;
                                                                        border-style: solid;
                                                                        color: #ffffff;
                                                                      "
                                                                      target="_blank"
                                                                      >BADGES</a
                                                                    >
                                                                  </td>
                                                                </tr>
                                                              </tbody>
                                                            </table>
                                                          </td>
                                                        </tr>
                                                      </tbody>
                                                    </table>
                                                    <table
                                                      border="0"
                                                      cellpadding="0"
                                                      cellspacing="0"
                                                      class="module"
                                                      data-role="module-button"
                                                      data-type="button"
                                                      role="module"
                                                      style="table-layout: fixed"
                                                      width="100%"
                                                      data-muid="9faecb59-dc1a-4a48-ad3a-7a893b1fc41b"
                                                    >
                                                      <tbody>
                                                        <tr>
                                                          <td
                                                            align="center"
                                                            bgcolor=""
                                                            class="outer-td"
                                                            style="
                                                              padding: 0px 0px 0px 0px;
                                                            "
                                                          >
                                                            <table
                                                              border="0"
                                                              cellpadding="0"
                                                              cellspacing="0"
                                                              class="wrapper-mobile"
                                                              style="
                                                                text-align: center;
                                                              "
                                                            >
                                                              <tbody>
                                                                <tr>
                                                                  <td
                                                                    align="center"
                                                                    bgcolor="#01253d"
                                                                    class="inner-td"
                                                                    style="
                                                                      border-radius: 6px;
                                                                      font-size: 16px;
                                                                      text-align: center;
                                                                      background-color: inherit;
                                                                    "
                                                                  >
                                                                    <a
                                                                      href="https://www.instagram.com/p/CZVB_-iAgUD/"
                                                                      style="
                                                                        background-color: #01253d;
                                                                        border: 2px
                                                                          solid
                                                                          #ffffff;
                                                                        border-color: #ffffff;
                                                                        border-radius: 30px;
                                                                        border-width: 2px;
                                                                        color: #ffffff;
                                                                        display: inline-block;
                                                                        font-size: 16px;
                                                                        font-weight: bold;
                                                                        letter-spacing: 0px;
                                                                        line-height: normal;
                                                                        padding: 12px
                                                                          40px 12px
                                                                          40px;
                                                                        text-align: center;
                                                                        text-decoration: none;
                                                                        border-style: solid;
                                                                      "
                                                                      target="_blank"
                                                                      >TOKENS</a
                                                                    >
                                                                  </td>
                                                                </tr>
                                                              </tbody>
                                                            </table>
                                                          </td>
                                                        </tr>
                                                      </tbody>
                                                    </table>
                                                    <table
                                                      class="module"
                                                      role="module"
                                                      data-type="text"
                                                      border="0"
                                                      cellpadding="0"
                                                      cellspacing="0"
                                                      width="100%"
                                                      style="table-layout: fixed"
                                                      data-muid="378a178d-727b-4c10-aca9-5fe2cee40fa3.3"
                                                      data-mc-module-version="2019-10-22"
                                                    >
                                                      <tbody>
                                                        <tr>
                                                          <td
                                                            style="
                                                              padding: 25px 30px 15px 30px;
                                                              line-height: 20px;
                                                              text-align: inherit;
                                                            "
                                                            height="100%"
                                                            valign="top"
                                                            bgcolor=""
                                                            role="module-content"
                                                          >
                                                            <div>
                                                              <div
                                                                style="
                                                                  font-family: inherit;
                                                                  text-align: center;
                                                                "
                                                              >
                                                                <span
                                                                  style="
                                                                    font-style: normal;
                                                                    font-variant-ligatures: normal;
                                                                    font-variant-caps: normal;
                                                                    font-weight: 400;
                                                                    letter-spacing: normal;
                                                                    text-align: left;
                                                                    text-indent: 0px;
                                                                    text-transform: none;
                                                                    white-space: normal;
                                                                    word-spacing: 0px;
                                                                    -webkit-text-stroke-width: 0px;
                                                                    text-decoration-thickness: initial;
                                                                    text-decoration-style: initial;
                                                                    text-decoration-color: initial;
                                                                    float: none;
                                                                    display: inline;
                                                                    color: #ffffff;
                                                                    font-family: arial,
                                                                      helvetica,
                                                                      sans-serif;
                                                                    font-size: 18px;
                                                                  "
                                                                  >Para acederes à
                                                                  plataforma, basta
                                                                  clicares no botão
                                                                  abaixo e definires
                                                                  a
                                                                  palavra-passe!</span
                                                                >
                                                              </div>
                                                              <div></div>
                                                            </div>
                                                          </td>
                                                        </tr>
                                                      </tbody>
                                                    </table>
                                                    <table
                                                      border="0"
                                                      cellpadding="0"
                                                      cellspacing="0"
                                                      class="module"
                                                      data-role="module-button"
                                                      data-type="button"
                                                      role="module"
                                                      style="table-layout: fixed"
                                                      width="100%"
                                                      data-muid="9faecb59-dc1a-4a48-ad3a-7a893b1fc41b.1"
                                                    >
                                                      <tbody>
                                                        <tr>
                                                          <td
                                                            align="center"
                                                            bgcolor=""
                                                            class="outer-td"
                                                            style="
                                                              padding: 0px 0px 0px 0px;
                                                            "
                                                          >
                                                            <table
                                                              border="0"
                                                              cellpadding="0"
                                                              cellspacing="0"
                                                              class="wrapper-mobile"
                                                              style="
                                                                text-align: center;
                                                              "
                                                            >
                                                              <tbody>
                                                                <tr>
                                                                  <td
                                                                    align="center"
                                                                    bgcolor="#36DBEE"
                                                                    class="inner-td"
                                                                    style="
                                                                      border-radius: 6px;
                                                                      font-size: 16px;
                                                                      text-align: center;
                                                                      background-color: inherit;
                                                                    "
                                                                  >
                                                                    <a
                                                                      href="#{password_reset_link}"
                                                                      style="
                                                                        background-color: #36dbee;
                                                                        border: 1px
                                                                          solid
                                                                          #36dbee;
                                                                        border-color: #36dbee;
                                                                        border-radius: 30px;
                                                                        border-width: 1px;
                                                                        color: #ffffff;
                                                                        display: inline-block;
                                                                        font-size: 16px;
                                                                        font-weight: bold;
                                                                        letter-spacing: 0px;
                                                                        line-height: normal;
                                                                        padding: 12px
                                                                          40px 12px
                                                                          40px;
                                                                        text-align: center;
                                                                        text-decoration: none;
                                                                        border-style: solid;
                                                                      "
                                                                      target="_blank"
                                                                      >CHECK IN</a
                                                                    >
                                                                  </td>
                                                                </tr>
                                                              </tbody>
                                                            </table>
                                                          </td>
                                                        </tr>
                                                      </tbody>
                                                    </table>
                                                    <table
                                                      class="module"
                                                      role="module"
                                                      data-type="spacer"
                                                      border="0"
                                                      cellpadding="0"
                                                      cellspacing="0"
                                                      width="100%"
                                                      style="table-layout: fixed"
                                                      data-muid="7866c83a-6e32-40ed-9ca8-907735ecb4f4"
                                                    >
                                                      <tbody>
                                                        <tr>
                                                          <td
                                                            style="
                                                              padding: 0px 0px 30px
                                                                0px;
                                                            "
                                                            role="module-content"
                                                            bgcolor=""
                                                          ></td>
                                                        </tr>
                                                      </tbody>
                                                    </table>
                                                    <table
                                                      class="module"
                                                      role="module"
                                                      data-type="text"
                                                      border="0"
                                                      cellpadding="0"
                                                      cellspacing="0"
                                                      width="100%"
                                                      style="table-layout: fixed"
                                                      data-muid="378a178d-727b-4c10-aca9-5fe2cee40fa3.2"
                                                      data-mc-module-version="2019-10-22"
                                                    >
                                                      <tbody>
                                                        <tr>
                                                          <td
                                                            style="
                                                              padding: 18px 30px
                                                                10px 30px;
                                                              line-height: 20px;
                                                              text-align: inherit;
                                                            "
                                                            height="100%"
                                                            valign="top"
                                                            bgcolor=""
                                                            role="module-content"
                                                          >
                                                            <div>
                                                              <div
                                                                style="
                                                                  font-family: inherit;
                                                                  text-align: center;
                                                                "
                                                              >
                                                                <span
                                                                  style="
                                                                    font-style: normal;
                                                                    font-variant-ligatures: normal;
                                                                    font-variant-caps: normal;
                                                                    font-weight: 400;
                                                                    letter-spacing: normal;
                                                                    text-align: left;
                                                                    text-indent: 0px;
                                                                    text-transform: none;
                                                                    white-space: normal;
                                                                    word-spacing: 0px;
                                                                    -webkit-text-stroke-width: 0px;
                                                                    text-decoration-thickness: initial;
                                                                    text-decoration-style: initial;
                                                                    text-decoration-color: initial;
                                                                    float: none;
                                                                    display: inline;
                                                                    color: #ffffff;
                                                                    font-family: arial,
                                                                      helvetica,
                                                                      sans-serif;
                                                                    font-size: 18px;
                                                                  "
                                                                  >Não te esqueças
                                                                  de passar no
                                                                  balcão da
                                                                  Acreditação, no
                                                                  CP2, a partir das
                                                                  09h15 do dia 15 de
                                                                  fevereiro, para </span
                                                                ><span
                                                                  style="
                                                                    font-style: normal;
                                                                    font-variant-ligatures: normal;
                                                                    font-variant-caps: normal;
                                                                    font-weight: 400;
                                                                    letter-spacing: normal;
                                                                    text-align: left;
                                                                    text-indent: 0px;
                                                                    text-transform: none;
                                                                    white-space: normal;
                                                                    word-spacing: 0px;
                                                                    -webkit-text-stroke-width: 0px;
                                                                    text-decoration-thickness: initial;
                                                                    text-decoration-style: initial;
                                                                    text-decoration-color: initial;
                                                                    float: none;
                                                                    display: inline;
                                                                    color: #ffffff;
                                                                    font-family: arial,
                                                                      helvetica,
                                                                      sans-serif;
                                                                    font-size: 18px;
                                                                  "
                                                                  ><strong
                                                                    >redimires a tua
                                                                    credencial</strong
                                                                  ></span
                                                                ><span
                                                                  style="
                                                                    font-style: normal;
                                                                    font-variant-ligatures: normal;
                                                                    font-variant-caps: normal;
                                                                    font-weight: 400;
                                                                    letter-spacing: normal;
                                                                    text-align: left;
                                                                    text-indent: 0px;
                                                                    text-transform: none;
                                                                    white-space: normal;
                                                                    word-spacing: 0px;
                                                                    -webkit-text-stroke-width: 0px;
                                                                    text-decoration-thickness: initial;
                                                                    text-decoration-style: initial;
                                                                    text-decoration-color: initial;
                                                                    float: none;
                                                                    display: inline;
                                                                    color: #ffffff;
                                                                    font-family: arial,
                                                                      helvetica,
                                                                      sans-serif;
                                                                    font-size: 18px;
                                                                  "
                                                                >
                                                                  e poderes aceder
                                                                  às atividades e
                                                                  receber
                                                                  badges!</span
                                                                >
                                                              </div>
                                                              <div
                                                                style="
                                                                  font-family: inherit;
                                                                  text-align: center;
                                                                "
                                                              >
                                                                <br />
                                                              </div>
                                                              <div></div>
                                                            </div>
                                                          </td>
                                                        </tr>
                                                      </tbody>
                                                    </table>
                                                    <table
                                                      class="module"
                                                      role="module"
                                                      data-type="text"
                                                      border="0"
                                                      cellpadding="0"
                                                      cellspacing="0"
                                                      width="100%"
                                                      style="table-layout: fixed"
                                                      data-muid="378a178d-727b-4c10-aca9-5fe2cee40fa3.2.1"
                                                    >
                                                      <tbody>
                                                        <tr>
                                                          <td
                                                            style="
                                                              padding: 18px 30px
                                                                10px 30px;
                                                              line-height: 20px;
                                                              text-align: inherit;
                                                            "
                                                            height="100%"
                                                            valign="top"
                                                            bgcolor=""
                                                            role="module-content"
                                                          >
                                                            <div>
                                                              <div
                                                                style="
                                                                  font-family: inherit;
                                                                  text-align: center;
                                                                "
                                                              >
                                                                <span
                                                                  style="
                                                                    font-style: normal;
                                                                    font-variant-ligatures: normal;
                                                                    font-variant-caps: normal;
                                                                    font-weight: 400;
                                                                    letter-spacing: normal;
                                                                    text-align: left;
                                                                    text-indent: 0px;
                                                                    text-transform: none;
                                                                    white-space: normal;
                                                                    word-spacing: 0px;
                                                                    -webkit-text-stroke-width: 0px;
                                                                    text-decoration-thickness: initial;
                                                                    text-decoration-style: initial;
                                                                    text-decoration-color: initial;
                                                                    float: none;
                                                                    display: inline;
                                                                    color: #36dbee;
                                                                    font-family: arial,
                                                                      helvetica,
                                                                      sans-serif;
                                                                    font-size: 18px;
                                                                  "
                                                                  ><strong
                                                                    >É obrigatório
                                                                    apresentar um
                                                                    certificado de
                                                                    vacinação,
                                                                    recuperação ou
                                                                    testagem válido
                                                                    no momento da
                                                                    acreditação.</strong
                                                                  ></span
                                                                >
                                                              </div>
                                                              <div></div>
                                                            </div>
                                                          </td>
                                                        </tr>
                                                      </tbody>
                                                    </table>
                                                    <table
                                                      class="wrapper"
                                                      role="module"
                                                      data-type="image"
                                                      border="0"
                                                      cellpadding="0"
                                                      cellspacing="0"
                                                      width="100%"
                                                      style="table-layout: fixed"
                                                      data-muid="72d01afa-d997-473f-a60c-20d56a921344"
                                                    >
                                                      <tbody>
                                                        <tr>
                                                          <td
                                                            style="
                                                              font-size: 6px;
                                                              line-height: 10px;
                                                              padding: 53px 21px 0px
                                                                17px;
                                                            "
                                                            valign="top"
                                                            align="center"
                                                          >
                                                            <img
                                                              class="max-width"
                                                              border="0"
                                                              style="
                                                                display: block;
                                                                color: #000000;
                                                                text-decoration: none;
                                                                font-family: Helvetica,
                                                                  arial, sans-serif;
                                                                font-size: 16px;
                                                                max-width: 72% !important;
                                                                width: 72%;
                                                                height: auto !important;
                                                              "
                                                              width="NaN"
                                                              alt=""
                                                              data-proportionally-constrained="false"
                                                              data-responsive="true"
                                                              src="https://sei22-prod.s3.eu-west-3.amazonaws.com/emails/sei-mascot.png"
                                                            />
                                                          </td>
                                                        </tr>
                                                      </tbody>
                                                    </table>
                                                  </td>
                                                </tr>
                                              </tbody>
                                            </table>
                                          </td>
                                        </tr>
                                      </tbody>
                                    </table>
                                    <table
                                      class="module"
                                      role="module"
                                      data-type="social"
                                      align="center"
                                      border="0"
                                      cellpadding="0"
                                      cellspacing="0"
                                      width="100%"
                                      style="table-layout: fixed"
                                      data-muid="3444e208-c089-4d18-92d6-6f68172dfdf3"
                                    >
                                      <tbody>
                                        <tr>
                                          <td
                                            valign="top"
                                            style="
                                              padding: 37px 0px 32px 0px;
                                              font-size: 6px;
                                              line-height: 10px;
                                              background-color: #36dbee;
                                            "
                                            align="center"
                                          >
                                            <table
                                              align="center"
                                              style="
                                                -webkit-margin-start: auto;
                                                -webkit-margin-end: auto;
                                              "
                                            >
                                              <tbody>
                                                <tr align="center">
                                                  <td
                                                    style="padding: 0px 5px"
                                                    class="social-icon-column"
                                                  >
                                                    <a
                                                      role="social-icon-link"
                                                      href="https://www.facebook.com/sei.uminho"
                                                      target="_blank"
                                                      alt="Facebook"
                                                      title="Facebook"
                                                      style="
                                                        display: inline-block;
                                                        background-color: #01253d;
                                                        height: 47px;
                                                        width: 47px;
                                                        border-radius: 12px;
                                                        -webkit-border-radius: 12px;
                                                        -moz-border-radius: 12px;
                                                      "
                                                    >
                                                      <img
                                                        role="social-icon"
                                                        alt="Facebook"
                                                        title="Facebook"
                                                        src="https://mc.sendgrid.com/assets/social/white/facebook.png"
                                                        style="
                                                          height: 47px;
                                                          width: 47px;
                                                        "
                                                        height="47"
                                                        width="47"
                                                      />
                                                    </a>
                                                  </td>
                                                  <td
                                                    style="padding: 0px 5px"
                                                    class="social-icon-column"
                                                  >
                                                    <a
                                                      role="social-icon-link"
                                                      href="https://www.instagram.com/sei.uminho/"
                                                      target="_blank"
                                                      alt="Instagram"
                                                      title="Instagram"
                                                      style="
                                                        display: inline-block;
                                                        background-color: #01253d;
                                                        height: 47px;
                                                        width: 47px;
                                                        border-radius: 12px;
                                                        -webkit-border-radius: 12px;
                                                        -moz-border-radius: 12px;
                                                      "
                                                    >
                                                      <img
                                                        role="social-icon"
                                                        alt="Instagram"
                                                        title="Instagram"
                                                        src="https://mc.sendgrid.com/assets/social/white/instagram.png"
                                                        style="
                                                          height: 47px;
                                                          width: 47px;
                                                        "
                                                        height="47"
                                                        width="47"
                                                      />
                                                    </a>
                                                  </td>
                                                  <td
                                                    style="padding: 0px 5px"
                                                    class="social-icon-column"
                                                  >
                                                    <a
                                                      role="social-icon-link"
                                                      href="https://www.linkedin.com/company/sei-cesium"
                                                      target="_blank"
                                                      alt="LinkedIn"
                                                      title="LinkedIn"
                                                      style="
                                                        display: inline-block;
                                                        background-color: #01253d;
                                                        height: 47px;
                                                        width: 47px;
                                                        border-radius: 12px;
                                                        -webkit-border-radius: 12px;
                                                        -moz-border-radius: 12px;
                                                      "
                                                    >
                                                      <img
                                                        role="social-icon"
                                                        alt="LinkedIn"
                                                        title="LinkedIn"
                                                        src="https://mc.sendgrid.com/assets/social/white/linkedin.png"
                                                        style="
                                                          height: 47px;
                                                          width: 47px;
                                                        "
                                                        height="47"
                                                        width="47"
                                                      />
                                                    </a>
                                                  </td>
                                                </tr>
                                              </tbody>
                                            </table>
                                          </td>
                                        </tr>
                                      </tbody>
                                    </table>
                                    <table
                                      border="0"
                                      cellpadding="0"
                                      cellspacing="0"
                                      align="center"
                                      width="100%"
                                      role="module"
                                      data-type="columns"
                                      style="padding: 50px 30px 50px 30px"
                                      bgcolor="#01253d"
                                      data-distribution="1"
                                    >
                                      <tbody>
                                        <tr role="module-content">
                                          <td height="100%" valign="top">
                                            <table
                                              width="540"
                                              style="
                                                width: 540px;
                                                border-spacing: 0;
                                                border-collapse: collapse;
                                                margin: 0px 0px 0px 0px;
                                              "
                                              cellpadding="0"
                                              cellspacing="0"
                                              align="left"
                                              border="0"
                                              bgcolor=""
                                              class="column column-0"
                                            >
                                              <tbody>
                                                <tr>
                                                  <td
                                                    style="
                                                      padding: 0px;
                                                      margin: 0px;
                                                      border-spacing: 0;
                                                    "
                                                  >
                                                    <table
                                                      class="module"
                                                      role="module"
                                                      data-type="text"
                                                      border="0"
                                                      cellpadding="0"
                                                      cellspacing="0"
                                                      width="100%"
                                                      style="table-layout: fixed"
                                                      data-muid="378a178d-727b-4c10-aca9-5fe2cee40fa3.1"
                                                      data-mc-module-version="2019-10-22"
                                                    >
                                                      <tbody>
                                                        <tr>
                                                          <td
                                                            style="
                                                              padding: 18px 30px -2px
                                                                30px;
                                                              line-height: 20px;
                                                              text-align: inherit;
                                                            "
                                                            height="100%"
                                                            valign="top"
                                                            bgcolor=""
                                                            role="module-content"
                                                          >
                                                            <div>
                                                              <div
                                                                style="
                                                                  font-family: inherit;
                                                                  text-align: center;
                                                                "
                                                              >
                                                                <span
                                                                  style="
                                                                    color: #ffffff;
                                                                    font-family: Colfax,
                                                                      Helvetica,
                                                                      Arial,
                                                                      sans-serif;
                                                                    font-style: normal;
                                                                    font-variant-ligatures: normal;
                                                                    font-variant-caps: normal;
                                                                    font-weight: 400;
                                                                    letter-spacing: normal;
                                                                    text-align: left;
                                                                    text-indent: 0px;
                                                                    text-transform: none;
                                                                    white-space: normal;
                                                                    word-spacing: 0px;
                                                                    -webkit-text-stroke-width: 0px;
                                                                    background-color: rgb(
                                                                      1,
                                                                      37,
                                                                      61
                                                                    );
                                                                    text-decoration-thickness: initial;
                                                                    text-decoration-style: initial;
                                                                    text-decoration-color: initial;
                                                                    float: none;
                                                                    display: inline;
                                                                    font-size: 18px;
                                                                  "
                                                                  >Consulta a agenda
                                                                  completa
                                                                  aqui...</span
                                                                >
                                                              </div>
                                                              <div
                                                                style="
                                                                  font-family: inherit;
                                                                  text-align: center;
                                                                "
                                                              >
                                                                <br />
                                                              </div>
                                                              <div></div>
                                                            </div>
                                                          </td>
                                                        </tr>
                                                      </tbody>
                                                    </table>
                                                    <table
                                                      border="0"
                                                      cellpadding="0"
                                                      cellspacing="0"
                                                      class="module"
                                                      data-role="module-button"
                                                      data-type="button"
                                                      role="module"
                                                      style="table-layout: fixed"
                                                      width="100%"
                                                      data-muid="9faecb59-dc1a-4a48-ad3a-7a893b1fc41b.2"
                                                    >
                                                      <tbody>
                                                        <tr>
                                                          <td
                                                            align="center"
                                                            bgcolor=""
                                                            class="outer-td"
                                                            style="
                                                              padding: 0px 0px 0px
                                                                0px;
                                                            "
                                                          >
                                                            <table
                                                              border="0"
                                                              cellpadding="0"
                                                              cellspacing="0"
                                                              class="wrapper-mobile"
                                                              style="
                                                                text-align: center;
                                                              "
                                                            >
                                                              <tbody>
                                                                <tr>
                                                                  <td
                                                                    align="center"
                                                                    bgcolor="#36DBEE"
                                                                    class="inner-td"
                                                                    style="
                                                                      border-radius: 6px;
                                                                      font-size: 16px;
                                                                      text-align: center;
                                                                      background-color: inherit;
                                                                    "
                                                                  >
                                                                    <a
                                                                      href="https://www.seium.org/schedule"
                                                                      style="
                                                                        background-color: #36dbee;
                                                                        border: 1px
                                                                          solid
                                                                          #36dbee;
                                                                        border-color: #36dbee;
                                                                        border-radius: 30px;
                                                                        border-width: 1px;
                                                                        color: #ffffff;
                                                                        display: inline-block;
                                                                        font-size: 17px;
                                                                        font-weight: bold;
                                                                        letter-spacing: 0px;
                                                                        line-height: normal;
                                                                        padding: 12px
                                                                          40px 12px
                                                                          40px;
                                                                        text-align: center;
                                                                        text-decoration: none;
                                                                        border-style: solid;
                                                                      "
                                                                      target="_blank"
                                                                      >AGENDA</a
                                                                    >
                                                                  </td>
                                                                </tr>
                                                              </tbody>
                                                            </table>
                                                          </td>
                                                        </tr>
                                                      </tbody>
                                                    </table>
                                                    <table
                                                      class="module"
                                                      role="module"
                                                      data-type="spacer"
                                                      border="0"
                                                      cellpadding="0"
                                                      cellspacing="0"
                                                      width="100%"
                                                      style="table-layout: fixed"
                                                      data-muid="e82028b3-5c5a-4901-ae3f-06a377eac34b"
                                                    >
                                                      <tbody>
                                                        <tr>
                                                          <td
                                                            style="
                                                              padding: 0px 0px 30px
                                                                0px;
                                                            "
                                                            role="module-content"
                                                            bgcolor=""
                                                          ></td>
                                                        </tr>
                                                      </tbody>
                                                    </table>
                                                    <table
                                                      class="module"
                                                      role="module"
                                                      data-type="text"
                                                      border="0"
                                                      cellpadding="0"
                                                      cellspacing="0"
                                                      width="100%"
                                                      style="table-layout: fixed"
                                                      data-muid="378a178d-727b-4c10-aca9-5fe2cee40fa3.1.1"
                                                    >
                                                      <tbody>
                                                        <tr>
                                                          <td
                                                            style="
                                                              padding: 18px 30px -5px
                                                                30px;
                                                              line-height: 20px;
                                                              text-align: inherit;
                                                            "
                                                            height="100%"
                                                            valign="top"
                                                            bgcolor=""
                                                            role="module-content"
                                                          >
                                                            <div>
                                                              <div
                                                                style="
                                                                  font-family: inherit;
                                                                  text-align: center;
                                                                "
                                                              >
                                                                <span
                                                                  style="
                                                                    color: #ffffff;
                                                                    font-family: Colfax,
                                                                      Helvetica,
                                                                      Arial,
                                                                      sans-serif;
                                                                    font-style: normal;
                                                                    font-variant-ligatures: normal;
                                                                    font-variant-caps: normal;
                                                                    font-weight: 400;
                                                                    letter-spacing: normal;
                                                                    text-align: left;
                                                                    text-indent: 0px;
                                                                    text-transform: none;
                                                                    white-space: normal;
                                                                    word-spacing: 0px;
                                                                    -webkit-text-stroke-width: 0px;
                                                                    background-color: rgb(
                                                                      1,
                                                                      37,
                                                                      61
                                                                    );
                                                                    text-decoration-thickness: initial;
                                                                    text-decoration-style: initial;
                                                                    text-decoration-color: initial;
                                                                    float: none;
                                                                    display: inline;
                                                                    font-size: 18px;
                                                                  "
                                                                  >...e junta-te ao
                                                                  Discord!&nbsp;</span
                                                                >
                                                              </div>
                                                              <div
                                                                style="
                                                                  font-family: inherit;
                                                                  text-align: center;
                                                                "
                                                              >
                                                                <br />
                                                              </div>
                                                              <div></div>
                                                            </div>
                                                          </td>
                                                        </tr>
                                                      </tbody>
                                                    </table>
                                                    <table
                                                      border="0"
                                                      cellpadding="0"
                                                      cellspacing="0"
                                                      class="module"
                                                      data-role="module-button"
                                                      data-type="button"
                                                      role="module"
                                                      style="table-layout: fixed"
                                                      width="100%"
                                                      data-muid="9faecb59-dc1a-4a48-ad3a-7a893b1fc41b.2.1"
                                                    >
                                                      <tbody>
                                                        <tr>
                                                          <td
                                                            align="center"
                                                            bgcolor=""
                                                            class="outer-td"
                                                            style="
                                                              padding: 0px 0px 0px
                                                                0px;
                                                            "
                                                          >
                                                            <table
                                                              border="0"
                                                              cellpadding="0"
                                                              cellspacing="0"
                                                              class="wrapper-mobile"
                                                              style="
                                                                text-align: center;
                                                              "
                                                            >
                                                              <tbody>
                                                                <tr>
                                                                  <td
                                                                    align="center"
                                                                    bgcolor="#01253d"
                                                                    class="inner-td"
                                                                    style="
                                                                      border-radius: 6px;
                                                                      font-size: 16px;
                                                                      text-align: center;
                                                                      background-color: inherit;
                                                                    "
                                                                  >
                                                                    <a
                                                                      href="#{discord_invite_url}"
                                                                      style="
                                                                        background-color: #01253d;
                                                                        border: 2px
                                                                          solid
                                                                          #ffffff;
                                                                        border-color: #ffffff;
                                                                        border-radius: 30px;
                                                                        border-width: 2px;
                                                                        color: #ffffff;
                                                                        display: inline-block;
                                                                        font-size: 17px;
                                                                        font-weight: bold;
                                                                        letter-spacing: 0px;
                                                                        line-height: normal;
                                                                        padding: 12px
                                                                          40px 12px
                                                                          40px;
                                                                        text-align: center;
                                                                        text-decoration: none;
                                                                        border-style: solid;
                                                                      "
                                                                      target="_blank"
                                                                      >DISCORD</a
                                                                    >
                                                                  </td>
                                                                </tr>
                                                              </tbody>
                                                            </table>
                                                          </td>
                                                        </tr>
                                                      </tbody>
                                                    </table>
                                                  </td>
                                                </tr>
                                              </tbody>
                                            </table>
                                          </td>
                                        </tr>
                                      </tbody>
                                    </table>
                                    <table
                                      class="module"
                                      role="module"
                                      data-type="text"
                                      border="0"
                                      cellpadding="0"
                                      cellspacing="0"
                                      width="100%"
                                      style="table-layout: fixed"
                                      data-muid="255f84b0-ed45-44f3-ba36-7002f8c2a281.1.1.1"
                                      data-mc-module-version="2019-10-22"
                                    >
                                      <tbody>
                                        <tr>
                                          <td
                                            style="
                                              padding: 50px 40px 50px 40px;
                                              line-height: 32px;
                                              text-align: inherit;
                                              background-color: #36dbee;
                                            "
                                            height="100%"
                                            valign="top"
                                            bgcolor="#36dbee"
                                            role="module-content"
                                          >
                                            <div>
                                              <div
                                                style="
                                                  font-family: inherit;
                                                  text-align: center;
                                                "
                                              >
                                                <span
                                                  style="
                                                    color: #ffffff;
                                                    font-size: 34px;
                                                  "
                                                  ><strong>HAVE A </strong></span
                                                ><span
                                                  style="
                                                    font-size: 34px;
                                                    color: #063d66;
                                                  "
                                                  ><strong>SEI</strong></span
                                                ><span
                                                  style="
                                                    color: #ffffff;
                                                    font-size: 34px;
                                                  "
                                                  ><strong
                                                    >-SATIONAL WEEK!</strong
                                                  ></span
                                                >
                                              </div>
                                              <div
                                                style="
                                                  font-family: inherit;
                                                  text-align: center;
                                                "
                                              >
                                                <span
                                                  style="
                                                    color: #ffffff;
                                                    font-size: 34px;
                                                  "
                                                  ><strong>AND STAY </strong></span
                                                ><span
                                                  style="
                                                    font-size: 34px;
                                                    color: #063d66;
                                                  "
                                                  ><strong>SEI</strong></span
                                                ><span
                                                  style="
                                                    color: #ffffff;
                                                    font-size: 34px;
                                                  "
                                                  ><strong>-FE!</strong></span
                                                >
                                              </div>
                                              <div
                                                style="
                                                  font-family: inherit;
                                                  text-align: center;
                                                "
                                              >
                                                <span
                                                  style="
                                                    box-sizing: border-box;
                                                    padding-top: 0px;
                                                    padding-right: 0px;
                                                    padding-bottom: 0px;
                                                    padding-left: 0px;
                                                    margin-top: 0px;
                                                    margin-right: 0px;
                                                    margin-bottom: 0px;
                                                    margin-left: 0px;
                                                    font-style: inherit;
                                                    font-variant-ligatures: inherit;
                                                    font-variant-caps: inherit;
                                                    font-variant-numeric: inherit;
                                                    font-variant-east-asian: inherit;
                                                    font-weight: inherit;
                                                    font-stretch: inherit;
                                                    line-height: inherit;
                                                    font-family: inherit;
                                                    font-size: 14px;
                                                    vertical-align: baseline;
                                                    border-top-width: 0px;
                                                    border-right-width: 0px;
                                                    border-bottom-width: 0px;
                                                    border-left-width: 0px;
                                                    border-top-style: initial;
                                                    border-right-style: initial;
                                                    border-bottom-style: initial;
                                                    border-left-style: initial;
                                                    border-top-color: initial;
                                                    border-right-color: initial;
                                                    border-bottom-color: initial;
                                                    border-left-color: initial;
                                                    border-image-source: initial;
                                                    border-image-slice: initial;
                                                    border-image-width: initial;
                                                    border-image-outset: initial;
                                                    border-image-repeat: initial;
                                                    letter-spacing: normal;
                                                    text-indent: 0px;
                                                    text-transform: none;
                                                    word-spacing: 0px;
                                                    -webkit-text-stroke-width: 0px;
                                                    background-color: rgb(
                                                      54,
                                                      219,
                                                      238
                                                    );
                                                    text-decoration-thickness: initial;
                                                    text-decoration-style: initial;
                                                    text-decoration-color: initial;
                                                    text-align: left;
                                                    white-space: normal;
                                                    color: #ffffff;
                                                  "
                                                  >A equipa organizadora da
                                                  SEI'22</span
                                                ><span style="color: #ffffff">
                                                  &nbsp;</span
                                                >
                                              </div>
                                              <div></div>
                                            </div>
                                          </td>
                                        </tr>
                                      </tbody>
                                    </table>
                                    <table
                                      class="module"
                                      role="module"
                                      data-type="text"
                                      border="0"
                                      cellpadding="0"
                                      cellspacing="0"
                                      width="100%"
                                      style="table-layout: fixed"
                                      data-muid="255f84b0-ed45-44f3-ba36-7002f8c2a281"
                                      data-mc-module-version="2019-10-22"
                                    >
                                      <tbody>
                                        <tr>
                                          <td
                                            style="
                                              padding: 11px 32px 15px 38px;
                                              line-height: 15px;
                                              text-align: inherit;
                                              background-color: #f7f7f7;
                                            "
                                            height="100%"
                                            valign="top"
                                            bgcolor="#f7f7f7"
                                            role="module-content"
                                          >
                                            <div>
                                              <div
                                                style="
                                                  font-family: inherit;
                                                  text-align: center;
                                                "
                                              >
                                                <span
                                                  style="
                                                    box-sizing: border-box;
                                                    padding-top: 0px;
                                                    padding-right: 0px;
                                                    padding-bottom: 0px;
                                                    padding-left: 0px;
                                                    margin-top: 0px;
                                                    margin-right: 0px;
                                                    margin-bottom: 0px;
                                                    margin-left: 0px;
                                                    font-style: inherit;
                                                    font-variant-ligatures: inherit;
                                                    font-variant-caps: inherit;
                                                    font-variant-numeric: inherit;
                                                    font-variant-east-asian: inherit;
                                                    font-weight: inherit;
                                                    font-stretch: inherit;
                                                    line-height: inherit;
                                                    vertical-align: baseline;
                                                    border-top-width: 0px;
                                                    border-right-width: 0px;
                                                    border-bottom-width: 0px;
                                                    border-left-width: 0px;
                                                    border-top-style: initial;
                                                    border-right-style: initial;
                                                    border-bottom-style: initial;
                                                    border-left-style: initial;
                                                    border-top-color: initial;
                                                    border-right-color: initial;
                                                    border-bottom-color: initial;
                                                    border-left-color: initial;
                                                    border-image-source: initial;
                                                    border-image-slice: initial;
                                                    border-image-width: initial;
                                                    border-image-outset: initial;
                                                    border-image-repeat: initial;
                                                    letter-spacing: normal;
                                                    text-indent: 0px;
                                                    text-transform: none;
                                                    word-spacing: 0px;
                                                    -webkit-text-stroke-width: 0px;
                                                    text-decoration-thickness: initial;
                                                    text-decoration-style: initial;
                                                    text-decoration-color: initial;
                                                    text-align: left;
                                                    white-space: normal;
                                                    font-family: arial, helvetica,
                                                      sans-serif;
                                                    color: #7d7d7d;
                                                    font-size: 10px;
                                                  "
                                                  >Se o botão de check-in não
                                                  funcionar, copia este link para o
                                                  teu browser:</span
                                                >
                                              </div>
                                              <div
                                                style="
                                                  font-family: inherit;
                                                  text-align: center;
                                                "
                                              >
                                                <span
                                                  style="
                                                    box-sizing: border-box;
                                                    padding-top: 0px;
                                                    padding-right: 0px;
                                                    padding-bottom: 0px;
                                                    padding-left: 0px;
                                                    margin-top: 0px;
                                                    margin-right: 20px;
                                                    margin-bottom: 20px;
                                                    margin-left: 20px;
                                                    font-style: inherit;
                                                    font-variant-ligatures: inherit;
                                                    font-variant-caps: inherit;
                                                    font-variant-numeric: inherit;
                                                    font-variant-east-asian: inherit;
                                                    font-weight: inherit;
                                                    font-stretch: inherit;
                                                    line-height: 18px;
                                                    vertical-align: middle;
                                                    border-top-width: 0px;
                                                    border-right-width: 0px;
                                                    border-bottom-width: 0px;
                                                    border-left-width: 0px;
                                                    border-top-style: initial;
                                                    border-right-style: initial;
                                                    border-bottom-style: initial;
                                                    border-left-style: initial;
                                                    border-top-color: initial;
                                                    border-right-color: initial;
                                                    border-bottom-color: initial;
                                                    border-left-color: initial;
                                                    border-image-source: initial;
                                                    border-image-slice: initial;
                                                    border-image-width: initial;
                                                    border-image-outset: initial;
                                                    border-image-repeat: initial;
                                                    outline-color: initial;
                                                    outline-style: none;
                                                    outline-width: initial;
                                                    text-decoration-line: none;
                                                    text-decoration-thickness: initial;
                                                    text-decoration-style: initial;
                                                    text-decoration-color: initial;
                                                    transition-duration: 0.3s;
                                                    transition-timing-function: ease;
                                                    transition-delay: 0s;
                                                    transition-property: color;
                                                    letter-spacing: normal;
                                                    text-align: left;
                                                    text-indent: 0px;
                                                    text-transform: none;
                                                    white-space: normal;
                                                    word-spacing: 0px;
                                                    -webkit-text-stroke-width: 0px;
                                                    font-family: arial, helvetica,
                                                      sans-serif;
                                                    color: #7d7d7d;
                                                    font-size: 10px;
                                                  "
                                                  >#{password_reset_link}</span
                                                ><span
                                                  style="
                                                    color: #7d7d7d;
                                                    font-size: 10px;
                                                  "
                                                  >&nbsp;</span
                                                >
                                              </div>
                                              <div></div>
                                            </div>
                                          </td>
                                        </tr>
                                      </tbody>
                                    </table>
                                  </td>
                                </tr>
                              </table>
                              <!--[if mso]>
                                      </td>
                                    </tr>
                                  </table>
                                </center>
                                <![endif]-->
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </div>
        </center>
      </body>
    </html>
    """
  end
end
